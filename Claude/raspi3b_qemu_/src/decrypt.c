/* decrypt.c - decrypt and verify data
 * Copyright (C) 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006,
 *               2007, 2009 Free Software Foundation, Inc.
 *
 * This file is part of GnuPG.
 *
 * GnuPG is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * GnuPG is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <https://www.gnu.org/licenses/>.
 */

#include "common/config.h"
// #include <stdio.h>
#include <stdlib.h>
#include <string.h>
// #include <errno.h>

#include "gpg.h"
#include "options.h"
#include "packet.h"
#include "common/status.h"
#include "common/iobuf.h"
// #include "common/iobuf.h"
// #include "keydb.h"
#include "common/util.h"
// #include "main.h"
#include "common/status.h"
#include "common/i18n.h"
#include "fwddecl.h"
#include "printf.h"
#include "memory.h"


int decrypt_memory(ctrl_t ctrl, const unsigned char* data, size_t length) {
    printf("decrypt_memory\n");
    // printf("Decrypt params:\n");
    // printf("Data ptr: %p\n", (void*)data);
    // printf("Session key: %s\n", ctrl->session_key);
    ctrl->enc_length=length;
    // printf("Decrypt params: %d\n",ctrl->enc_length);
    iobuf_t a;
    int rc;
    gnupg_fd_t fp;
    file_filter_ctx_t *fcx;
    size_t len = 0;
    int print_only = 0;

    const char *opentype = "rb";
    const char *fname = NULL;
    int fd = 0;
    int use = 0;
    /* Create input iobuf from memory */
    a = iobuf_temp_with_content((const char*)data, length);
    
    if (!a) {
        return gpg_error_from_syserror();
    }
    iobuf_fdopen (translate_file_handle (fd, use == IOBUF_INPUT ? 0 : 1),
			 opentype);

	  fp = fd_cache_open (NULL, opentype);
    fcx = xmalloc (sizeof *fcx + strlen (fname));
    fcx->fp = fp;
    fcx->print_only_name = print_only;
    strcpy (fcx->fname, fname);
    if (!print_only)
      a->real_fname = xstrdup (fname);
    a->filter = file_filter;
    fcx->no_cache = 1;
    a->filter_ov = fcx;

    // printf("Added\n");
    file_filter (fcx, IOBUFCTRL_INIT, NULL, NULL, &len);
    /* Add block filter for OpenPGP format */
    // block_filter_ctx_t *bfx = xcalloc(1, sizeof *bfx);
    // bfx->use = IOBUF_INPUT;
    // bfx->size = 0;  /* Unknown size - read until EOF */
    // rc = iobuf_push_filter(a, block_filter, bfx);
    // if (rc) {
    //     iobuf_close(a);
    //     return rc;
    // }

    /* Process encryption packets */
    rc = proc_encryption_packets(ctrl, NULL, a);
    // return -1;
    printf("\n\nEND decrypt_memory\n\n");
    /* Clean up */
    // iobuf_close(a);
    return rc;
}


/* Assume that the input is an encrypted message and decrypt
 * (and if signed, verify the signature on) it.
 * This command differs from the default operation, as it never
 * writes to the filename which is included in the file and it
 * rejects files which don't begin with an encrypted message.
 */
int
decrypt_message (ctrl_t ctrl, const char *filename)
{
  printf("decrypt_message filename:%s\n",filename);
  IOBUF fp;
//   armor_filter_context_t *afx = NULL;
//   progress_filter_context_t *pfx;
  int rc;

//   pfx = new_progress_context ();

  /* Open the message file.  */
  fp = iobuf_open (filename);
//   if (fp && is_secured_file (iobuf_get_fd (fp)))
//     {
//       iobuf_close (fp);
//       fp = NULL;
// //      gpg_err_set_errno (-1);//EPERM);
//     }else{
//       printf("ELSE\n");
//     }

// instead:
iobuf_get_fd (fp);
  if ( !fp )
    {
      rc = gpg_error_from_syserror ();
//      printf (("can't open '%s': %s\n"), print_fname_stdin(filename),
                 // gpg_strerror (rc));
    //   release_progress_context (pfx);
      return rc;
    }

//   handle_progress (pfx, fp, filename);

//   if ( !opt.no_armor )
//     {
//     //   if ( use_armor_filter( fp ) )
//         {
//         //   afx = new_armor_context ();
//         //   push_armor_filter ( afx, fp );
// 	}
//     }

//   if (!opt.outfile)
//     {
//       opt.outfile = "-";
//       opt.flags.dummy_outfile = 1;
//     }
//   else
//     opt.flags.dummy_outfile = 0;
  printf("opt.outfile:%s\n",opt.outfile);
  rc = proc_encryption_packets (ctrl, NULL, fp );
//   if (opt.flags.dummy_outfile)
//     opt.outfile = NULL;

  iobuf_close (fp);
//   release_armor_context (afx);
//   release_progress_context (pfx);
  return rc;
}
