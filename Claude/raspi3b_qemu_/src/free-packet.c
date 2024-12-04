// /* free-packet.c - cleanup stuff for packets
//  * Copyright (C) 1998, 1999, 2000, 2001, 2002, 2003,
//  *               2005, 2010  Free Software Foundation, Inc.
//  *
//  * This file is part of GnuPG.
//  *
//  * GnuPG is free software; you can redistribute it and/or modify
//  * it under the terms of the GNU General Public License as published by
//  * the Free Software Foundation; either version 3 of the License, or
//  * (at your option) any later version.
//  *
//  * GnuPG is distributed in the hope that it will be useful,
//  * but WITHOUT ANY WARRANTY; without even the implied warranty of
//  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  * GNU General Public License for more details.
//  *
//  * You should have received a copy of the GNU General Public License
//  * along with this program; if not, see <https://www.gnu.org/licenses/>.
//  */

// #include "config.h"
// #include <stdio.h>
// #include <stdlib.h>
// #include <string.h>

// // #include "gpg.h"
// // #include "../common/util.h"
// #include "packet.h"
// #include "iobuf.h"
// // #include "options.h"


// void
// free_symkey_enc( PKT_symkey_enc *enc )
// {
//     xfree(enc);
// }


// void
// free_encrypted( PKT_encrypted *ed )
// {
//   if (!ed)
//     return;

//   if (ed->buf)
//     {
//       /* We need to skip some bytes. */
//       if (ed->is_partial)
//         {
//           while (iobuf_read( ed->buf, NULL, 1<<30 ) != -1)
//             ;
// 	}
//       else
//         {
//           while (ed->len)
//             {
//               /* Skip the packet. */
//               int n = iobuf_read( ed->buf, NULL, ed->len );
//               if (n == -1)
//                 ed->len = 0;
//               else
//                 ed->len -= n;
//             }
// 	}
//     }
//   xfree (ed);
// }


// void
// free_plaintext( PKT_plaintext *pt )
// {
//   if (!pt)
//     return;

//   if (pt->buf)
//     { /* We need to skip some bytes.  */
//       if (pt->is_partial)
//         {
//           while (iobuf_read( pt->buf, NULL, 1<<30 ) != -1)
//             ;
//         }
//       else
//         {
//           while( pt->len )
//             { /* Skip the packet.  */
//               int n = iobuf_read( pt->buf, NULL, pt->len );
//               if (n == -1)
//                 pt->len = 0;
//               else
//                 pt->len -= n;
//             }
// 	}
//     }
//   xfree (pt);
// }


// /****************
//  * Free the packet in PKT.
//  */
// void
// free_packet (PACKET *pkt, parse_packet_ctx_t parsectx)
// {
//   if (!pkt || !pkt->pkt.generic)
//     {
//       if (parsectx && parsectx->last_pkt.pkt.generic)
//         {
//           if (parsectx->free_last_pkt)
//             {
//               free_packet (&parsectx->last_pkt, NULL);
//               parsectx->free_last_pkt = 0;
//             }
//           parsectx->last_pkt.pkttype = 0;
//           parsectx->last_pkt.pkt.generic = NULL;
//         }
//       return;
//     }

//   // if (DBG_MEMORY)
//   //   log_debug ("free_packet() type=%d\n", pkt->pkttype);

//   /* If we have a parser context holding PKT then do not free the
//    * packet but set a flag that the packet in the parser context is
//    * now a deep copy.  */
//   if (parsectx && !parsectx->free_last_pkt
//       && parsectx->last_pkt.pkttype == pkt->pkttype
//       && parsectx->last_pkt.pkt.generic == pkt->pkt.generic)
//     {
//       parsectx->last_pkt = *pkt;
//       parsectx->free_last_pkt = 1;
//       pkt->pkt.generic = NULL;
//       return;
//     }

//   switch (pkt->pkttype)
//     {
//     // case PKT_SIGNATURE:
//     //   free_seckey_enc (pkt->pkt.signature);
//     //   break;
//     // case PKT_PUBKEY_ENC:
//     //   free_pubkey_enc (pkt->pkt.pubkey_enc);
//     //   break;
//     case PKT_SYMKEY_ENC:
//       free_symkey_enc (pkt->pkt.symkey_enc);
//       break;
//     // case PKT_PUBLIC_KEY:
//     // case PKT_PUBLIC_SUBKEY:
//     // case PKT_SECRET_KEY:
//     // case PKT_SECRET_SUBKEY:
//     //   free_public_key (pkt->pkt.public_key);
//     //   break;
//     // case PKT_COMMENT:
//     //   free_comment (pkt->pkt.comment);
//     //   break;
//     // case PKT_USER_ID:
//     //   free_user_id (pkt->pkt.user_id);
//     //   break;
//     // case PKT_COMPRESSED:
//     //   free_compressed (pkt->pkt.compressed);
//     //   break;
//     case PKT_ENCRYPTED:
//     // case PKT_ENCRYPTED_MDC:
//     // case PKT_ENCRYPTED_AEAD:
//     //   free_encrypted (pkt->pkt.encrypted);
//     //   break;
//     case PKT_PLAINTEXT:
//       free_plaintext (pkt->pkt.plaintext);
//       break;
//     default:
//       xfree (pkt->pkt.generic);
//       break;
//     }

//   pkt->pkt.generic = NULL;
// }

