;###########################################################################
;##                                                                       ##
;##                  Language Technologies Institute                      ##
;##                     Carnegie Mellon University                        ##
;##                       Copyright (c) 2010-2011                         ##
;##                        All Rights Reserved.                           ##
;##                                                                       ##
;##  Permission is hereby granted, free of charge, to use and distribute  ##
;##  this software and its documentation without restriction, including   ##
;##  without limitation the rights to use, copy, modify, merge, publish,  ##
;##  distribute, sublicense, and/or sell copies of this work, and to      ##
;##  permit persons to whom this work is furnished to do so, subject to   ##
;##  the following conditions:                                            ##
;##   1. The code must retain the above copyright notice, this list of    ##
;##      conditions and the following disclaimer.                         ##
;##   2. Any modifications must be clearly marked as such.                ##
;##   3. Original authors' names are not deleted.                         ##
;##   4. The authors' names are not used to endorse or promote products   ##
;##      derived from this software without specific prior written        ##
;##      permission.                                                      ##
;##                                                                       ##
;##  CARNEGIE MELLON UNIVERSITY AND THE CONTRIBUTORS TO THIS WORK         ##
;##  DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING      ##
;##  ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT   ##
;##  SHALL CARNEGIE MELLON UNIVERSITY NOR THE CONTRIBUTORS BE LIABLE      ##
;##  FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES    ##
;##  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN   ##
;##  AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,          ##
;##  ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF       ##
;##  THIS SOFTWARE.                                                       ##
;##                                                                       ##
;###########################################################################
;##                                                                       ##
;##            Authors: Alok Parlikar                                     ##
;##            Email:   aup@cs.cmu.edu                                    ##
;##                                                                       ##
;###########################################################################
;##                                                                       ##
;##  Prosodic Phrasing with support for Syntactic Phrasing Model          ##
;##                                                                       ##
;###########################################################################

;;; Load any necessary files here

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (INST_LANG_VOX::select_phrasing)
  "Set up phrasing"
 (INST_LANG_VOX::select_phrasing_default ))
(define (INST_LANG_VOX::select_phrasing_default)
  "(INST_LANG_VOX::select_phrasing)
Set up the phrasing module."

       (set! INST_LANG_phrase_cart_tree
             '
             ((lisp_token_end_punc in ("'" "\"" "?" "." "," ":" ";"))
              ((B))
              ((n.name is 0)
               ((B))
               ((NB)))))))




  (set! phrase_cart_tree INST_LANG_phrase_cart_tree)
  (Parameter.set 'Phrase_Method 'cart_tree)
)


(define (INST_LANG_VOX::reset_phrasing)
  "Reset phrasing" )



(provide 'INST_LANG_VOX_phrasing)
