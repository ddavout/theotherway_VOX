;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                                                     ;;;
;;;                     Carnegie Mellon University                      ;;;
;;;                  and Alan W Black and Kevin Lenzo                   ;;;
;;;                      Copyright (c) 1998-2000                        ;;;
;;;                        All Rights Reserved.                         ;;;
;;;                                                                     ;;;
;;; Permission is hereby granted, free of charge, to use and distribute ;;;
;;; this software and its documentation without restriction, including  ;;;
;;; without limitation the rights to use, copy, modify, merge, publish, ;;;
;;; distribute, sublicense, and/or sell copies of this work, and to     ;;;
;;; permit persons to whom this work is furnished to do so, subject to  ;;;
;;; the following conditions:                                           ;;;
;;;  1. The code must retain the above copyright notice, this list of   ;;;
;;;     conditions and the following disclaimer.                        ;;;
;;;  2. Any modifications must be clearly marked as such.               ;;;
;;;  3. Original authors' names are not deleted.                        ;;;
;;;  4. The authors' names are not used to endorse or promote products  ;;;
;;;     derived from this software without specific prior written       ;;;
;;;     permission.                                                     ;;;
;;;                                                                     ;;;
;;; CARNEGIE MELLON UNIVERSITY AND THE CONTRIBUTORS TO THIS WORK        ;;;
;;; DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING     ;;;
;;; ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT  ;;;
;;; SHALL CARNEGIE MELLON UNIVERSITY NOR THE CONTRIBUTORS BE LIABLE     ;;;
;;; FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES   ;;;
;;; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN  ;;;
;;; AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,         ;;;
;;; ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF      ;;;
;;; THIS SOFTWARE.                                                      ;;;
;;;                                                                     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Lexicon, LTS and Postlexical rules for INST_LANG_lex
;;;
;;; Load any necessary files here
(require 'INST_LANG_postlex)
;(require 'INST_LANG/INST_LANG_lex)
(define (setup_INST_LANG_lex)
  "(setup_INST_LANG_lex)
  lexicon Includes letter to sound
  rule model trained from this data"
  (if (not (member_string "INST_LANG_lex" (lex.list)))
      (load (path-append lexdir "INST_LANG/INST_LANG_lex.scm"))))

;;;
(define (INST_LANG_VOX::select_lexicon)
  "Set up the lexicon."
  (setup_INST_LANG_lex)
  (set! lastlex  (lex.select "INST_LANG_lex"))
  (if debug (format t "ici: INST_LANG_VOX:select\n"))
  ;; Post lexical rules
  (set! prevpostlexruleshooks postlex_rules_hooks)
  (lex.set.pre_hooks 'INST_LANG_lex_pre_hook_function)
  ;; XXX
  ; par défaut on a (set! postlex_rules_hooks (list INST_LANG_lex::postlex_corr))
  (set! postlex_rules_hooks (list INST_LANG_lex::postlex_corr)) t)


;;;
(define (INST_LANG_VOX::reset_lexicon)
  "(INST_LANG_VOX::reset_lexicon)
  Reset lexicon information."
  (set! postlex_rules_hooks (list INST_LANG_lex::postlex_corr))
  t)
;;;
(provide 'INST_LANG_VOX_lexicon) 
