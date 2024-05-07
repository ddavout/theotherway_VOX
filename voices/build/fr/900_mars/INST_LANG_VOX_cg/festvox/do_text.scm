; (set! text "une variable globale")
; (set! addenda_dir "ADDENDA")
; (set! textes_dir "textes")
(set! dSayText null); pour voir seulement
(define (do_text addenda_filename)
   "save the text of the addenda in textes_dir"
   (let ( ofd
          (prompt_name (path-basename addenda_filename ))
           )
        (if (probe_file addenda_filename)
            (begin 
                (format  t  "loading addenda_filename %s\n" addenda_filename )
                (load addenda_filename)
                (if (not (string-equal text ""))
                    (begin 
                        (set! ofd (fopen  (string-append textes_dir "/" prompt_name ".txt") "w"))
                        ;(format ofd "\( \"%s\" \)" text)
                        (format ofd "%s" text)
                        (fclose ofd))
                    (begin 
                      (format t "text not set in %s/n" prompt_name)
                      (set! text ""))))
                    
            (begin 
                (error t "missing addenda %s\n" addenda_filename)
                ))))

