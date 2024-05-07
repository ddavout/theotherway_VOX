(define (do_prompt fname text) 
  "(do_prompt fname text) 
  Synthesize given text and save waveform and labels for prompts."
  (set! INST_LANG_VOX::clunits_prompting_stage t)
  (voice_INST_LANG_VOX_clunits)
  (Parameter.set 'Synth_Method 'None)

  (eval (list INST_LANG_VOX::closest_voice))
  (unwind-protect
    (begin
      (eval addenda_dir)
      (eval prompt_utt_ext)
      (eval prompt_utt_dir)
      (eval prompt_lab_ext)
      (eval prompt_lab_dir))
    (error "one of the variables addenda_dir, prompt_utt_ext, prompt_utt_dir, prompt_lab_ext, prompt_lab_dir is not set"))


  (let ((utt1) (addenda_filename))
    (format t "do_prompt %s %s\n" fname text)
    (INST_LANG_VOX::reset_lexicon); retour FF/1_clunits
    (set! addenda_filename (format nil "%s/%s" addenda_dir fname))
    (format t "do_prompt addenda_filename: %s\n" addenda_filename)
    (if (probe_file addenda_filename)
        (unwind-protect
          (load addenda_filename)
          (error "wrong addenda" addenda_filename )))

    (set! postlex_rules_hooks (list INST_LANG_lex::postlex_corr))
    (unwind-protect 
      (begin 
        ;(set! utt1 (utt.synth (eval (list 'Utterance 'Text (norm text)))))
        (set! utt1 (utt.synth (eval (list 'Utterance 'Text text))))

        (format t "flat: %l" (utt.flat_repr utt1))
        )
       (error "bad utt.synth" fname))
    (unwind-protect 
      (begin
       (format t "info: %s/%s%s\n" prompt_utt_dir fname prompt_utt_ext)
       (utt.save utt1 (format nil "%s/%s%s" prompt_utt_dir fname prompt_utt_ext)))
      (error "problem  saving prompt_utt\n" fname))
    (unwind-protect
      (begin
       (format t "info: %s/%s%s\n" prompt_lab_dir fname prompt_lab_ext)
       (utt.save.segs utt1 (format nil "%s/%s%s" prompt_lab_dir fname prompt_lab_ext)))
      (error "problem  saving prompt_lab" fname))
    t))

