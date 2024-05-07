(set! INST_LANG_VOX::dir "./")
(set! load-path (cons (path-append INST_LANG_VOX::dir "festvox/") 
		      load-path))
(set! load-path (cons "/home/dop7/Develop/festival/lib/INST_LANG"
           		      load-path))
(set! load-path (cons "/home/dop7/Develop/festival/lib/dicts/INST_LANG"
           		      load-path))   
(require 'INST_LANG_phones)
(require 'INST_LANG_VOX_phoneset)
(INST_LANG_VOX::select_phoneset)
;(PhoneSet.select "INST_LANG") 
