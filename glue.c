/* Storage for the two BSS-style globals NKCOMPR.LIB references but never
 * strongly defines.
 *
 * In MSVC COFF an "extern" with section=UNDEF and a non-zero value field
 * is a tentative (common) definition; the linker would normally allocate
 * that many bytes of zeroed storage at link time.  objconv lowers those
 * to plain UND ELF symbols, so ld leaves them unresolved unless we
 * provide them here.
 *
 *   LZBLOCKBITS - 4 bytes - log2(blocksize) used by both the LZ77 codec
 *                 and the ROM decompressor.  Both functions write it on
 *                 entry, so its initial value doesn't matter.
 *   lz77Globals - 0x502c bytes - working state for the LZ77 codec.
 */
unsigned int  LZBLOCKBITS;
unsigned char lz77Globals[0x502c];
