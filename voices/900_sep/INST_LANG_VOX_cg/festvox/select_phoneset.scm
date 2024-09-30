(set! INST_LANG_VOX::dir "./")
(set! load-path (cons (path-append INST_LANG_VOX::dir "festvox/") 
              load-path))
(set! load-path (cons "/home/getac/Develop/festival/lib/INST_LANG"
                      load-path))
(set! load-path (cons "/home/getac/Develop/festival/lib/dicts/INST_LANG"
                      load-path))   
(load "/home/getac/Develop/festival/lib/voices/LANG/INST_LANG_VOX_cg/festvox/INST_LANG_VOX_phoneset.scm" )

(INST_LANG_VOX::select_phoneset)
;(PhoneSet.select "INST_LANG")   
