#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fontconfig/fontconfig.h>

/**
 * fontconfig_helper.c
 * 
 * Native C helper for reading system fonts via libfontconfig.
 * Returns a JSON array string of all installed fonts.
 * Called from Dart via FFI for maximum performance.
 */

// Escape special JSON characters in a string
static void json_escape(const char *src, char *dst, size_t dst_size) {
    size_t j = 0;
    for (size_t i = 0; src[i] != '\0' && j < dst_size - 1; i++) {
        switch (src[i]) {
            case '"':  if (j + 2 < dst_size) { dst[j++] = '\\'; dst[j++] = '"'; } break;
            case '\\': if (j + 2 < dst_size) { dst[j++] = '\\'; dst[j++] = '\\'; } break;
            case '\n': if (j + 2 < dst_size) { dst[j++] = '\\'; dst[j++] = 'n'; } break;
            case '\r': if (j + 2 < dst_size) { dst[j++] = '\\'; dst[j++] = 'r'; } break;
            case '\t': if (j + 2 < dst_size) { dst[j++] = '\\'; dst[j++] = 't'; } break;
            default:   dst[j++] = src[i]; break;
        }
    }
    dst[j] = '\0';
}

/**
 * get_system_fonts_json()
 * 
 * Queries fontconfig for all installed fonts and returns a JSON string.
 * The caller (Dart) is responsible for calling free_fonts_json() on the result.
 * 
 * Returns: malloc'd JSON string like:
 * [{"family":"Ubuntu","style":"Regular","file":"/usr/share/fonts/...","weight":80,"slant":0,"spacing":0}, ...]
 */
char* get_system_fonts_json(void) {
    FcConfig *config = FcInitLoadConfigAndFonts();
    if (!config) {
        char *err = strdup("[]");
        return err;
    }

    // Create an empty pattern to match ALL fonts
    FcPattern *pattern = FcPatternCreate();
    
    // Specify which properties we want
    FcObjectSet *os = FcObjectSetBuild(
        FC_FAMILY,
        FC_STYLE,
        FC_FILE,
        FC_WEIGHT,
        FC_SLANT,
        FC_SPACING,
        (char *) 0
    );

    // Query all fonts
    FcFontSet *fs = FcFontList(config, pattern, os);
    
    if (!fs || fs->nfont == 0) {
        if (pattern) FcPatternDestroy(pattern);
        if (os) FcObjectSetDestroy(os);
        if (fs) FcFontSetDestroy(fs);
        FcConfigDestroy(config);
        char *empty = strdup("[]");
        return empty;
    }

    // Pre-allocate buffer (estimate ~300 bytes per font)
    size_t buf_size = (size_t)fs->nfont * 350 + 64;
    char *result = (char *)malloc(buf_size);
    if (!result) {
        FcPatternDestroy(pattern);
        FcObjectSetDestroy(os);
        FcFontSetDestroy(fs);
        FcConfigDestroy(config);
        return strdup("[]");
    }

    size_t pos = 0;
    result[pos++] = '[';

    char escaped[512];

    for (int i = 0; i < fs->nfont; i++) {
        FcPattern *font = fs->fonts[i];
        
        FcChar8 *family = NULL;
        FcChar8 *style = NULL;
        FcChar8 *file = NULL;
        int weight = 0;
        int slant = 0;
        int spacing = 0; // 0 = proportional, 100 = mono

        FcPatternGetString(font, FC_FAMILY, 0, &family);
        FcPatternGetString(font, FC_STYLE, 0, &style);
        FcPatternGetString(font, FC_FILE, 0, &file);
        FcPatternGetInteger(font, FC_WEIGHT, 0, &weight);
        FcPatternGetInteger(font, FC_SLANT, 0, &slant);
        FcPatternGetInteger(font, FC_SPACING, 0, &spacing);

        // Ensure we have enough space
        size_t needed = 512;
        if (pos + needed > buf_size) {
            buf_size *= 2;
            char *new_buf = (char *)realloc(result, buf_size);
            if (!new_buf) {
                free(result);
                FcPatternDestroy(pattern);
                FcObjectSetDestroy(os);
                FcFontSetDestroy(fs);
                FcConfigDestroy(config);
                return strdup("[]");
            }
            result = new_buf;
        }

        if (i > 0) {
            result[pos++] = ',';
        }

        // Build JSON object for this font
        const char *fam = family ? (const char *)family : "";
        const char *sty = style ? (const char *)style : "";
        const char *fil = file ? (const char *)file : "";

        char esc_family[256], esc_style[256], esc_file[512];
        json_escape(fam, esc_family, sizeof(esc_family));
        json_escape(sty, esc_style, sizeof(esc_style));
        json_escape(fil, esc_file, sizeof(esc_file));

        int written = snprintf(result + pos, buf_size - pos,
            "{\"family\":\"%s\",\"style\":\"%s\",\"file\":\"%s\",\"weight\":%d,\"slant\":%d,\"spacing\":%d}",
            esc_family, esc_style, esc_file, weight, slant, spacing);
        
        if (written > 0) {
            pos += (size_t)written;
        }
    }

    result[pos++] = ']';
    result[pos] = '\0';

    // Cleanup fontconfig resources
    FcPatternDestroy(pattern);
    FcObjectSetDestroy(os);
    FcFontSetDestroy(fs);
    FcConfigDestroy(config);

    return result;
}

/**
 * free_fonts_json()
 * 
 * Frees the memory allocated by get_system_fonts_json().
 * Must be called from Dart after the JSON string is consumed.
 */
void free_fonts_json(char *json) {
    if (json) {
        free(json);
    }
}
