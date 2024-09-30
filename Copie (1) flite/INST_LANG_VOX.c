/*************************************************************************/
/*                                                                       */
/*                  Language Technologies Institute                      */
/*                     Carnegie Mellon University                        */
/*                      Copyright (c) 1999-2000                          */
/*                        All Rights Reserved.                           */
/*                                                                       */
/*  Permission is hereby granted, free of charge, to use and distribute  */
/*  this software and its documentation without restriction, including   */
/*  without limitation the rights to use, copy, modify, merge, publish,  */
/*  distribute, sublicense, and/or sell copies of this work, and to      */
/*  permit persons to whom this work is furnished to do so, subject to   */
/*  the following conditions:                                            */
/*   1. The code must retain the above copyright notice, this list of    */
/*      conditions and the following disclaimer.                         */
/*   2. Any modifications must be clearly marked as such.                */
/*   3. Original authors' names are not deleted.                         */
/*   4. The authors' names are not used to endorse or promote products   */
/*      derived from this software without specific prior written        */
/*      permission.                                                      */
/*                                                                       */
/*  CARNEGIE MELLON UNIVERSITY AND THE CONTRIBUTORS TO THIS WORK         */
/*  DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING      */
/*  ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT   */
/*  SHALL CARNEGIE MELLON UNIVERSITY NOR THE CONTRIBUTORS BE LIABLE      */
/*  FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES    */
/*  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN   */
/*  AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,          */
/*  ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF       */
/*  THIS SOFTWARE.                                                       */
/*                                                                       */
/*************************************************************************/
/*             Author:  Alan W Black (awb@cs.cmu.edu)                    */
/*               Date:  April 2001                                       */
/*************************************************************************/
/*                                                                       */
/*  A simple clunits/ldom voice defintion			         */
/*                                                                       */
/*************************************************************************/

#include <string.h>
#include "flite.h"
#include "cst_clunits.h"
#include "INST_LANG_LANG_lang.h"
#include "INST_LANG_LANG_lex.h"

static char *INST_LANG_VOX_unit_name(cst_item *s);

extern cst_clunit_db INST_LANG_VOX_db;
cst_voice *INST_LANG_VOX_clunits = NULL;

extern const cst_cart INST_LANG_VOX_dur_cart;
extern const dur_stat * const INST_LANG_VOX_dur_stats[];

cst_voice *register_INST_LANG_VOX(const char *voxdir)
{
    cst_voice *v;
    cst_lexicon *lex;

    if (INST_LANG_VOX_clunits)
        return INST_LANG_VOX_clunits;  /* Already registered */

    v = new_voice();
    v->name = "VOX";

    /* Sets up language specific parameters in the INST_LANG_VOX. */
    INST_LANG_LANG_lang_init(v);

    /* Things that weren't filled in already. */
    flite_feat_set_string(v->features,"name","INST_LANG_VOX");

    /* Duration model */
    flite_feat_set(v->features,"dur_cart",cart_val(&INST_LANG_VOX_dur_cart));
    flite_feat_set(v->features,"dur_stats",dur_stats_val((dur_stats *)INST_LANG_VOX_dur_stats));

    /* Lexicon */
    lex = INST_LANG_LANG_lex_init();
    flite_feat_set(v->features,"lexicon",lexicon_val(lex));
    flite_feat_set(v->features,"postlex_func",uttfunc_val(lex->postlex));

    /* Waveform synthesis */
    flite_feat_set(v->features,"wave_synth_func",uttfunc_val(&clunits_synth));
    flite_feat_set(v->features,"clunit_db",clunit_db_val(&INST_LANG_VOX_db));
    flite_feat_set_int(v->features,"sample_rate",INST_LANG_VOX_db.sts->sample_rate);
    flite_feat_set_string(v->features,"join_type","simple_join");
    flite_feat_set_string(v->features,"resynth_type","fixed");

    if ((voxdir != NULL) &&
        (INST_LANG_VOX_db.sts->sts == NULL) &&
        (INST_LANG_VOX_db.sts->sts_paged == NULL) &&
        (INST_LANG_VOX_db.sts->frames == NULL))
        flite_mmap_clunit_voxdata(voxdir,v);

    /* Unit selection */
    INST_LANG_VOX_db.unit_name_func = INST_LANG_VOX_unit_name;

    INST_LANG_VOX_clunits = v;

    return INST_LANG_VOX_clunits;
}

void unregister_INST_LANG_VOX(cst_voice *vox)
{
    if (vox != INST_LANG_VOX_clunits)
	return;
    delete_voice(vox);
    INST_LANG_VOX_clunits = NULL;
}

static const char *INST_LANG_VOX_nextvoicing(cst_item *s)
{
    if (cst_streq("+",flite_ffeature_string(s,"n.ph_vc")))
        return "V";
    else if (cst_streq("+",flite_ffeature_string(s,"n.ph_cvox")))
        return "CVox";
    else
        return "UV";
}

static char *INST_LANG_VOX_unit_name(cst_item *s)
{
    const char *name;
    /* This *is* long enough as long as you don't change external things */
    char cname[30];

    name = flite_ffeature_string(s,"name");
    /* Comment this out if you have more complex unit names */
#if 1
    if (1 == 1)
        return cst_strdup(name);
    else 
#endif
    if (cst_streq("+",flite_ffeature_string(s,"ph_vc")))
    {
        cst_sprintf(cname,"%s_%s_%s",name,
                    flite_ffeature_string(s,"R:SylStructure.parent.stress"),
                    INST_LANG_VOX_nextvoicing(s));
    }
    else 
    {
        cst_sprintf(cname,"%s_%s",name,
                    INST_LANG_VOX_nextvoicing(s));
    }

    return cst_strdup(cname);
}
