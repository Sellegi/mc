.//====================================================================
.//
.// $RCSfile: q.val.translate.arc,v $
.//
.// (c) Copyright 1998-2010 Mentor Graphics Corporation  All rights reserved.
.//
.//====================================================================
.//
.// These functions set up the implementation of the values (V_VAL on
.// model of OAL).
.//
.//==================================================================== 
.//
.//
.//==================================================================== 
.//
.//--------------------------------------------------------------------
.// Percolate the values from the "leaves" up into the combined
.// expressions by recursively drilling down.
.//--------------------------------------------------------------------
.function gen_value
  .param inst_ref v_val
  .select one v_mvl related by v_val->V_MVL[R801]
  .if ( not_empty v_mvl )
    .invoke q_val_member_value( v_mvl )
  .else
  .select one v_avl related by v_val->V_AVL[R801]
  .if ( not_empty v_avl )
    .invoke q_val_attribute_value( v_avl )
  .else
  .select one v_aer related by v_val->V_AER[R801]
  .if ( not_empty v_aer )
    .invoke q_val_array_element_reference( v_aer )
  .else
  .select one v_alv related by v_val->V_ALV[R801]
  .if ( not_empty v_alv )
    .invoke q_val_array_length_value( v_alv )
  .else
  .select one v_uny related by v_val->V_UNY[R801]
  .if ( not_empty v_uny )
    .invoke q_val_unary_op_value( v_uny )
  .else
  .select one v_bin related by v_val->V_BIN[R801]
  .if ( not_empty v_bin )
    .invoke q_val_binary_op_value( v_bin )
  .else
  .select one v_trv related by v_val->V_TRV[R801]
  .if ( not_empty v_trv )
    .invoke q_val_transform_value( v_trv )
  .else
  .select one v_msv related by v_val->V_MSV[R801]
  .if ( not_empty v_msv )
    .invoke q_val_message_value( v_msv )
  .else
  .select one v_brv related by v_val->V_BRV[R801]
  .if ( not_empty v_brv )
    .invoke q_val_bridge_value( v_brv )
  .else
  .select one v_fnv related by v_val->V_FNV[R801]
  .if ( not_empty v_fnv )
    .invoke q_val_synch_service_value( v_fnv )
  .else
    .print "ERROR:  Recursive V_VAL resolution issue."
  .end if
  .end if
  .end if
  .end if
  .end if
  .end if
  .end if
  .end if
  .end if
  .end if
.end function
.//
.function q_val_literal_boolean_values
  .select many v_lbos from instances of V_LBO
  .for each v_lbo in v_lbos
    .select one te_val related by v_lbo->V_VAL[R801]->TE_VAL[R2040]
    .assign te_val.OAL = v_lbo.value
    .assign te_val.buffer = "$l{v_lbo.value}"
  .end for
.end function
.//
.function q_val_literal_string_values
  .select any te_string from instances of TE_STRING
  .select many v_lsts from instances of V_LST
  .for each v_lst in v_lsts
    .select one te_val related by v_lst->V_VAL[R801]->TE_VAL[R2040]
    .assign te_val.OAL = ( "'" + v_lst.Value ) + "'"
    .assign te_val.buffer = ( """" + v_lst.Value ) + """"
    .assign te_val.dimensions = 1
    .assign te_val.array_spec = ( "[" + te_string.max_string_length ) + "]"
  .end for
.end function
.//
.function q_val_literal_integer_values
  .select many v_lins from instances of V_LIN
  .for each v_lin in v_lins
    .select one te_val related by v_lin->V_VAL[R801]->TE_VAL[R2040]
    .assign te_val.OAL = v_lin.Value
    .assign te_val.buffer = v_lin.Value
  .end for
.end function
.//
.function q_val_literal_real_values
  .select many v_lrls from instances of V_LRL
  .for each v_lrl in v_lrls
    .select one te_val related by v_lrl->V_VAL[R801]->TE_VAL[R2040]
    .assign te_val.OAL = v_lrl.Value
    .assign te_val.buffer = v_lrl.Value
  .end for
.end function
.//
.function q_val_literal_enumerations
  .select many v_lens from instances of V_LEN
  .for each v_len in v_lens
    .select one te_val related by v_len->V_VAL[R801]->TE_VAL[R2040]
    .select one te_enum related by v_len->S_ENUM[R824]->TE_ENUM[R2027]
    .assign te_val.OAL = te_enum.Name
    .assign te_val.buffer = te_enum.GeneratedName
  .end for
.end function
.//
.function q_val_constant_values
  .select many v_scvs from instances of V_SCV
  .for each v_scv in v_scvs
    .select one te_val related by v_scv->V_VAL[R801]->TE_VAL[R2040]
    .select one cnst_syc related by v_scv->CNST_SYC[R850]
    .select one cnst_lsc related by cnst_syc->CNST_LFSC[R1502]->CNST_LSC[R1503]
    .select one te_dt related by cnst_syc->S_DT[R1500]->TE_DT[R2021]
    .assign te_val.OAL = cnst_syc.Name
    .assign te_val.buffer = cnst_lsc.Value
    .if ( 4 == te_dt.Core_Typ )
      .select any te_string from instances of TE_STRING
      .assign te_val.buffer = ( """" + cnst_lsc.Value ) + """"
      .assign te_val.dimensions = 1
      .assign te_val.array_spec = ( "[" + te_string.max_string_length ) + "]"
    .end if
  .end for
.end function
.//
.function q_val_transient_values
  .select many v_tvls from instances of V_TVL
  .for each v_tvl in v_tvls
    .select one v_var related by v_tvl->V_VAR[R805]
    .select one te_var related by v_var->TE_VAR[R2039]
    .select one te_val related by v_tvl->V_VAL[R801]->TE_VAL[R2040]
    .assign te_val.OAL = te_var.OAL
    .assign te_val.buffer = te_var.buffer
    .assign te_val.dimensions = te_var.dimensions
    .assign te_val.array_spec = te_var.array_spec
  .end for
.end function
.//
.function q_val_actual_parameters
  .select many v_pars from instances of V_PAR
  .for each v_par in v_pars
    .select one te_par related by v_par->TE_PAR[R2063]
    .select one v_val related by v_par->V_VAL[R800]
    .select one te_val related by v_val->TE_VAL[R2040]
    .select one te_dt related by v_val->S_DT[R820]->TE_DT[R2021]
    .assign te_val.OAL = ( te_par.Name + ":" ) + te_val.OAL
    .if ( 1 == te_par.By_Ref )
      .assign te_val.buffer = ( "&(" + te_val.buffer ) + ")"
    .end if
    .if ( 10 == te_dt.Core_Typ )
      .// Cast event types to the base event type for passing (to timers).
      .assign te_val.buffer = ( "(" + te_dt.ExtName ) + ( ")" + te_val.buffer )
    .end if
  .end for
.end function
.//
.function q_val_attribute_values
  .select many v_avls from instances of V_AVL
  .for each v_avl in v_avls
    .invoke q_val_attribute_value( v_avl )
  .end for
.end function
.//
.function q_val_attribute_value
  .param inst_ref v_avl
  .select one v_val related by v_avl->V_VAL[R801]
  .select one te_val related by v_val->TE_VAL[R2040]
  .if ( "" == te_val.buffer )
    .select one root_v_val related by v_avl->V_VAL[R807]
    .select one root_te_val related by root_v_val->TE_VAL[R2040]
    .if ( "" == root_te_val.buffer )
      .invoke gen_value( root_v_val )
    .end if
    .select one te_var related by v_avl->V_VAL[R807]->V_IRF[R801]->V_VAR[R808]->TE_VAR[R2039]
    .select one o_attr related by v_avl->O_ATTR[R806]
    .select one te_attr related by o_attr->TE_ATTR[R2033]
    .assign root = ""
    .if ( empty te_var )
      .assign te_val.OAL = ( root_te_val.OAL + "." ) + te_attr.Name
      .assign te_val.buffer = ( root_te_val.buffer + "->" ) + te_attr.GeneratedName
      .assign root = root_te_val.buffer
    .else
      .assign te_val.OAL = ( te_var.OAL + "." ) + te_attr.Name
      .assign te_val.buffer = ( te_var.buffer + "->" ) + te_attr.GeneratedName
      .assign root = te_var.buffer
    .end if 
    .assign te_val.dimensions = te_attr.dimensions
    .assign te_val.array_spec = te_attr.array_spec
    .// Maybe attribute value is actually derived.
    .select one o_dbattr related by o_attr->O_BATTR[R106]->O_DBATTR[R107]
    .if ( not_empty o_dbattr )
      .select one act_ai related by v_val->ACT_AI[R689]
      .if ( empty act_ai )
        .// Only do this if we are not assigning inside the DAB OAL body.
        .select one te_aba related by o_dbattr->TE_DBATTR[R2026]->TE_ABA[R2010]
        .assign te_val.buffer = ( te_aba.GeneratedName + "( " ) + ( root + " )" )
        .assign te_val.dimensions = te_aba.dimensions
        .assign te_val.array_spec = te_aba.array_spec
      .end if
    .end if
  .end if 
.end function
.//
.function q_val_member_values
  .select many v_mvls from instances of V_MVL
  .for each v_mvl in v_mvls
    .invoke q_val_member_value( v_mvl )
  .end for
.end function
.//
.function q_val_member_value
  .param inst_ref v_mvl
  .select one te_val related by v_mvl->V_VAL[R801]->TE_VAL[R2040]
  .if ( "" == te_val.buffer )
    .select one root_v_val related by v_mvl->V_VAL[R837]
    .select one root_te_val related by root_v_val->TE_VAL[R2040]
    .if ( "" == root_te_val.buffer )
      .invoke gen_value( root_v_val )
    .end if
    .select one te_mbr related by v_mvl->S_MBR[R836]->TE_MBR[R2047]
    .assign te_val.dimensions = te_mbr.dimensions
    .assign te_val.array_spec = te_mbr.array_spec
    .assign te_val.OAL = ( root_te_val.OAL + "." ) + te_mbr.Name
    .assign te_val.buffer = ( root_te_val.buffer + "." ) + te_mbr.GeneratedName
  .end if
.end function
.//
.function q_val_instance_reference_values
  .select many v_irfs from instances of V_IRF
  .for each v_irf in v_irfs
    .select one te_val related by v_irf->V_VAL[R801]->TE_VAL[R2040]
    .select one te_var related by v_irf->V_VAR[R808]->TE_VAR[R2039]
    .if ( not_empty te_var )
      .assign te_val.OAL = te_var.OAL
      .assign te_val.buffer = te_var.buffer
    .else
      .print "CDS:  Understand why we do not have V_VAR here."
      .assign te_val.buffer = "v_" + "${info.unique_num}"
    .end if
  .end for
.end function
.//
.function q_val_selection_test_values
  .select many v_slrs from instances of V_SLR
  .for each v_slr in v_slrs
    .select one te_val related by v_slr->V_VAL[R801]->TE_VAL[R2040]
    .assign te_val.buffer = "selected"
    .assign te_val.OAL = "SELECTED"
  .end for
.end function
.//
.function q_val_inst_ref_set_values
  .select many v_isrs from instances of V_ISR
  .for each v_isr in v_isrs
    .select one te_var related by v_isr->V_VAR[R809]->TE_VAR[R2039]
    .select one te_val related by v_isr->V_VAL[R801]->TE_VAL[R2040]
    .assign te_val.OAL = te_var.OAL
    .assign te_val.buffer = te_var.buffer
  .end for
.end function
.//
.function q_val_event_values
  .select many v_edvs from instances of V_EDV
  .for each v_edv in v_edvs
    .select one te_val related by v_edv->V_VAL[R801]->TE_VAL[R2040]
    .// If there are more than one transition into the state, there
    .// may be more than one event parameter reference.  Select
    .// any of them; they have the same names.
    .select any te_parm related by v_edv->V_EPR[R834]->SM_EVTDI[R846]->TE_PARM[R2031]
    .if ( empty te_parm )
      .select one te_parm related by v_edv->V_EPR[R834]->C_PP[R847]->TE_PARM[R2048]
    .else
      .// Mark the event as used.
      .select one te_evt related by te_parm->SM_EVTDI[R2031]->SM_EVT[R532]->TE_EVT[R2036]
      .assign te_evt.UsedCount = te_evt.UsedCount + 1
      .assign te_evt.Used = true
    .end if
    .assign te_val.OAL = "PARAM." + te_parm.Name
    .assign te_val.buffer = "rcvd_evt->" + te_parm.GeneratedName
    .assign te_val.dimensions = te_parm.dimensions
    .assign te_val.array_spec = te_parm.array_spec
  .end for
.end function
.//
.function q_val_parameter_values
  .select many v_pvls from instances of V_PVL
  .for each v_pvl in v_pvls
    .select one te_val related by v_pvl->V_VAL[R801]->TE_VAL[R2040]
    .select one te_parm related by v_pvl->O_TPARM[R833]->TE_PARM[R2029]
    .if ( empty te_parm )
    .select one te_parm related by v_pvl->C_PP[R843]->TE_PARM[R2048]
    .if ( empty te_parm )
    .select one te_parm related by v_pvl->S_SPARM[R832]->TE_PARM[R2030]
    .if ( empty te_parm )
    .select one te_parm related by v_pvl->S_BPARM[R831]->TE_PARM[R2028]
    .if ( empty te_parm )
      .print "CDS:  Understand why we do not have V_PVL related parameter here."
    .end if
    .end if
    .end if
    .end if
    .assign te_val.OAL = "PARAM." + te_parm.Name
    .assign te_val.buffer = te_parm.GeneratedName
    .assign te_val.dimensions = te_parm.dimensions
    .assign te_val.array_spec = te_parm.array_spec
    .if ( 1 == te_parm.By_Ref )
      .assign te_val.buffer = ( "(*" + te_parm.GeneratedName ) + ")"
    .end if
  .end for
.end function
.//
.function q_val_unary_op_values
  .select many v_unys from instances of V_UNY
  .for each v_uny in v_unys
    .invoke gen_unary_op_value( v_uny )
  .end for
.end function
.//
.function gen_unary_op_value
  .param inst_ref v_uny
  .select one te_val related by v_uny->V_VAL[R801]->TE_VAL[R2040]
  .if ( "" == te_val.buffer )
    .select one root_v_val related by v_uny->V_VAL[R804]
    .select one root_te_val related by root_v_val->TE_VAL[R2040]
    .if ( "" == root_te_val.buffer )
      .invoke gen_value( root_v_val )
    .end if
    .// Remove blanks and make lower case.
    .assign op = "$r{v_uny.Operator}"
    .assign op = "$l{op}"
    .select any te_set from instances of TE_SET
    .select one v_irf related by root_v_val->V_IRF[R801]
    .select one v_isr related by root_v_val->V_ISR[R801]
    .if ( not_empty v_irf )
      .if ( op == "not_empty" )
        .assign te_val.buffer = "( 0 != ${root_te_val.buffer} )"
      .elif ( op == "empty" )
        .assign te_val.buffer = "( 0 == ${root_te_val.buffer} )"
      .elif ( op == "cardinality" )
        .assign te_val.buffer = "( 0 != ${root_te_val.buffer} )"
      .else
        .print "ERROR:  Unary set operator ${v_uny.Operator} is not supported."
      .end if
    .elif ( not_empty v_isr )
      .if ( op == "not_empty" )
        .assign te_val.buffer = "( ! ${te_set.emptiness}( ${root_te_val.buffer} ) )"
      .elif ( op == "empty" )
        .assign te_val.buffer = "${te_set.emptiness}( ${root_te_val.buffer} )"
      .elif ( op == "cardinality" )
        .assign te_val.buffer = "${te_set.element_count}( ${root_te_val.buffer} )"
      .else
        .print "ERROR:  Unary set operator ${v_uny.Operator} is not supported."
      .end if
    .else
      .if ( op == "not" )
        .assign te_val.buffer = "!" + root_te_val.buffer
      .else
        .assign te_val.buffer = op + root_te_val.buffer
      .end if
    .end if
    .assign te_val.OAL = ( op + " " ) + root_te_val.OAL
    .assign te_val.dimensions = root_te_val.dimensions
    .assign te_val.array_spec = root_te_val.array_spec
  .end if
.end function
.//
.function q_val_binary_op_values
  .select many v_bins from instances of V_BIN
  .for each v_bin in v_bins
    .invoke q_val_binary_op_value( v_bin )
  .end for
.end function
.//
.function q_val_binary_op_value
  .param inst_ref v_bin
  .select one te_val related by v_bin->V_VAL[R801]->TE_VAL[R2040]
  .if ( "" == te_val.buffer )
    .select one l_v_val related by v_bin->V_VAL[R802]
    .select one l_te_val related by l_v_val->TE_VAL[R2040]
    .if ( "" == l_te_val.buffer )
      .invoke gen_value( l_v_val )
    .end if
    .select one r_v_val related by v_bin->V_VAL[R803]
    .select one r_te_val related by r_v_val->TE_VAL[R2040]
    .if ( "" == r_te_val.buffer )
      .invoke gen_value( r_v_val )
    .end if
    .select one l_te_dt related by l_v_val->S_DT[R820]->TE_DT[R2021]
    .select one r_te_dt related by r_v_val->S_DT[R820]->TE_DT[R2021]
    .if ( ( 4 == l_te_dt.Core_Typ ) or ( 4 == r_te_dt.Core_Typ ) )
      .// string
      .select any te_string from instances of TE_STRING
      .if ( "+" == "$r{v_bin.Operator}" )
        .assign te_val.buffer = "${te_string.stradd}( ${l_te_val.buffer}, ${r_te_val.buffer} )"
      .else
        .assign te_val.buffer = "( ${te_string.strcmp}( ${l_te_val.buffer}, ${r_te_val.buffer} ) ${v_bin.Operator} 0 )"
      .end if
    .else
      .if ( "and" == "$r{v_bin.Operator}" )
        .assign te_val.buffer = ( ( "( " + l_te_val.buffer ) + ( " && " + r_te_val.buffer ) ) + " )"
      .elif ( "or" == "$r{v_bin.Operator}" )
        .assign te_val.buffer = ( ( "( " + l_te_val.buffer ) + ( " || " + r_te_val.buffer ) ) + " )"
      .else
        .assign te_val.buffer = ( ( "( " + l_te_val.buffer ) + ( " " + v_bin.Operator ) ) + ( ( " " + r_te_val.buffer ) + " )" )
      .end if
    .end if
    .assign te_val.array_spec = r_te_val.array_spec
    .assign te_val.OAL = ( ( "( " + l_te_val.OAL ) + ( " " + v_bin.Operator ) ) + ( ( " " + r_te_val.OAL ) + " )" )
  .end if
.end function
.//
.function q_val_message_values
.select many v_msvs from instances of V_MSV
.for each v_msv in v_msvs
  .invoke q_val_message_value( v_msv )
.end for
.end function
.//
.function q_val_message_value
  .param inst_ref v_msv
  .select one v_val related by v_msv->V_VAL[R801]
  .select one te_val related by v_val->TE_VAL[R2040]
  .select many v_pars related by v_msv->V_PAR[R842]
  .select one te_mact related by v_msv->SPR_PEP[R841]->SPR_PO[R4503]->TE_MACT[R2050]
  .if ( empty te_mact )
    .select one te_mact related by v_msv->SPR_REP[R845]->SPR_RO[R4502]->TE_MACT[R2052]
  .end if
  .select one te_aba related by te_mact->TE_ABA[R2010]
  .invoke params = gen_parameter_list( v_pars, false, "message" )
  .assign te_val.OAL = "${te_mact.PortName}::${te_mact.MessageName}(${params.OAL})"
  .assign te_val.buffer = ( te_aba.scope + te_mact.GeneratedName ) + "("
  .if ( "" != params.body )
    .assign te_val.buffer = ( te_val.buffer + " " ) + ( params.body + " " )
  .end if
  .assign te_val.buffer = te_val.buffer + ")"
  .assign te_val.dimensions = te_aba.dimensions
  .assign te_val.array_spec = te_aba.array_spec
.end function
.//
.function q_val_bridge_values
  .select many v_brvs from instances of V_BRV
  .for each v_brv in v_brvs
    .invoke q_val_bridge_value( v_brv )
  .end for
.end function
.//
.function q_val_bridge_value
  .param inst_ref v_brv
  .select one v_val related by v_brv->V_VAL[R801]
  .select one te_val related by v_val->TE_VAL[R2040]
  .select many v_pars related by v_brv->V_PAR[R810]
  .select one te_brg related by v_brv->S_BRG[R828]->TE_BRG[R2025]
  .select one te_aba related by te_brg->TE_ABA[R2010]
  .invoke params = gen_parameter_list( v_pars, false, "bridge" )
  .assign te_val.OAL = "${te_brg.EEkeyletters}::${te_brg.Name}(${params.OAL})"
  .assign te_val.buffer = ( ( te_brg.EEkeyletters + "::" ) + ( te_brg.GeneratedName + "(" ) )
  .if ( "" != params.body )
    .assign te_val.buffer = ( te_val.buffer + " " ) + ( params.body + " " )
  .end if
  .assign te_val.buffer = te_val.buffer + ")"
  .assign te_val.dimensions = te_aba.dimensions
  .assign te_val.array_spec = te_aba.array_spec
.end function
.//
.function q_val_transform_values
  .select many v_trvs from instances of V_TRV
  .for each v_trv in v_trvs
    .invoke q_val_transform_value( v_trv )
  .end for
.end function
.//
.function q_val_transform_value
  .param inst_ref v_trv
  .select one v_val related by v_trv->V_VAL[R801]
  .select one te_val related by v_val->TE_VAL[R2040]
  .select many v_pars related by v_trv->V_PAR[R811]
  .select one te_tfr related by v_trv->O_TFR[R829]->TE_TFR[R2024]
  .select one te_aba related by te_tfr->TE_ABA[R2010]
  .assign te_val.buffer = te_tfr.GeneratedName + "("
  .if ( te_tfr.Instance_Based == 1 )
    .select one v_var related by v_trv->V_VAR[R830]
    .if ( not_empty v_var )
      .assign te_val.buffer = te_val.buffer + v_var.Name
      .assign te_val.OAL = v_var.Name + "."
    .else
      .// no variable, must be selection (selected reference)
      .assign te_val.buffer = te_val.buffer + "selected"
      .assign te_val.OAL = "SELECTED."
    .end if
  .else
    .assign te_val.OAL = te_tfr.Key_Lett + "::"
  .end if
  .invoke params = gen_parameter_list( v_pars, false, "operation" )
  .assign te_val.OAL = te_val.OAL + "${te_tfr.Name}(${params.OAL})"
  .if ( te_tfr.Instance_Based == 1 )
    .if ( "" != params.body )
      .assign te_val.buffer = te_val.buffer + ", "
    .end if
  .end if
  .assign te_val.buffer = ( te_val.buffer + params.body ) + ")"
  .assign te_val.dimensions = te_aba.dimensions
  .assign te_val.array_spec = te_aba.array_spec
.end function
.//
.function q_val_synch_service_values
  .select many v_fnvs from instances of V_FNV
  .for each v_fnv in v_fnvs
    .invoke q_val_synch_service_value( v_fnv )
  .end for
.end function
.//
.function q_val_synch_service_value
  .param inst_ref v_fnv
  .select one v_val related by v_fnv->V_VAL[R801]
  .select one te_val related by v_val->TE_VAL[R2040]
  .select many v_pars related by v_fnv->V_PAR[R817]
  .select one te_sync related by v_fnv->S_SYNC[R827]->TE_SYNC[R2023]
  .select one te_aba related by te_sync->TE_ABA[R2010]
  .invoke params = gen_parameter_list( v_pars, false, "function" )
  .assign te_val.OAL = "::${te_sync.Name}(${params.OAL})"
  .assign te_val.buffer = te_sync.intraface_method + "("
  .if ( "" != params.body )
    .assign te_val.buffer = ( te_val.buffer + " " ) + ( params.body + " " )
  .end if
  .assign te_val.buffer = te_val.buffer + ")"
  .assign te_val.dimensions = te_aba.dimensions
  .assign te_val.array_spec = te_aba.array_spec
.end function
.//
.function q_val_array_element_references
  .select many v_aers from instances of V_AER
  .for each v_aer in v_aers
    .invoke q_val_array_element_reference( v_aer )
  .end for
.end function
.//
.function q_val_array_element_reference
  .param inst_ref v_aer
  .select one te_val related by v_aer->V_VAL[R801]->TE_VAL[R2040]
  .if ( "" == te_val.buffer )
    .select one root_v_val related by v_aer->V_VAL[R838]
    .select one root_te_val related by root_v_val->TE_VAL[R2040]
    .if ( "" == root_te_val.buffer )
      .invoke gen_value( root_v_val )
    .end if
    .select one index_v_val related by v_aer->V_VAL[R839]
    .select one index_te_val related by index_v_val->TE_VAL[R2040]
    .if ( "" == index_te_val.buffer )
      .invoke gen_value( index_v_val )
    .end if
    .assign te_val.OAL = ( root_te_val.OAL + "[" ) + ( index_te_val.buffer + "]" )
    .assign te_val.buffer = ( root_te_val.buffer + "[" ) + ( index_te_val.buffer + "]" )
    .assign te_val.array_spec = root_te_val.array_spec
    .assign te_val.dimensions = root_te_val.dimensions
  .end if
.end function
.//
.function q_val_array_length_values
  .select many v_alvs from instances of V_ALV
  .for each v_alv in v_alvs
    .invoke q_val_array_length_value( v_alv )
  .end for
.end function
.//
.function q_val_array_length_value
  .param inst_ref v_alv
  .select one te_val related by v_alv->V_VAL[R801]->TE_VAL[R2040]
  .if ( "" == te_val.buffer )
    .select one root_v_val related by v_alv->V_VAL[R840]
    .select one root_te_val related by root_v_val->TE_VAL[R2040]
    .if ( "" == root_te_val.buffer )
      .invoke gen_value( root_v_val )
    .end if
    .assign te_val.OAL = root_te_val.OAL + ".length"
    .assign te_val.buffer = root_te_val.buffer + ".length"
  .end if
.end function
.//