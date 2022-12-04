function rate_13C_GLUT(Glucose_media_13C, Glucose_13C, Glucose_media, Glucose, params)
    Rate = (
        (params.GLUT_Vmax * params.GLUT_Conc / params.GLUT_Km_Glucose) *
        (Glucose_media_13C - (1 / params.GLUT_Keq) * Glucose_13C) /
        (1 + Glucose_media / params.GLUT_Km_Glucose + Glucose / params.GLUT_Km_Glucose)
    )
    return Rate
end

function rate_13C_HK1(Glucose_13C, G6P_13C, Glucose, G6P, ATP, Phosphate, ADP, params)
    Z = (
        (
            1 +
            (Glucose / params.HK1_K_Glucose) +
            (ATP / params.HK1_K_a_ATP) +
            (G6P / params.HK1_K_G6P) +
            (G6P / params.HK1_K_a_G6P_cat) +
            (ADP / params.HK1_K_a_ADP) +
            (params.HK1_β_Glucose_ATP) * (Glucose / params.HK1_K_Glucose) * (ATP / params.HK1_K_a_ATP) +
            (Glucose / params.HK1_K_Glucose) * (ADP / params.HK1_K_a_ADP) +
            (Glucose / params.HK1_K_Glucose) * (G6P / params.HK1_K_a_G6P_cat) +
            (G6P / params.HK1_K_G6P) * (ADP / params.HK1_K_a_ADP) +
            (G6P / params.HK1_K_G6P) * (G6P / params.HK1_K_a_G6P_cat)
        ) * (1 + (Phosphate / params.HK1_K_a_Pi)) +
        (1 + (Glucose / params.HK1_K_Glucose) + (G6P / params.HK1_K_G6P)) * (G6P / params.HK1_K_i_G6P_reg)
    )
    Rate =
        (
            (
                params.HK1_Vmax *
                params.HK1_Conc *
                (params.HK1_β_Glucose_ATP) *
                (1 / params.HK1_K_Glucose) *
                (1 / params.HK1_K_a_ATP) *
                (1 + (Phosphate / params.HK1_K_a_Pi))
            ) * (Glucose_13C * ATP - G6P_13C * ADP / params.HK1_Keq)
        ) / Z
    return Rate
end

function rate_13C_GPI(G6P_13C, F6P_13C, G6P, F6P, params)
    Rate = (
        (params.GPI_Vmax * params.GPI_Conc / params.GPI_Km_G6P) * (G6P_13C - (1 / params.GPI_Keq) * F6P_13C) /
        (1 + G6P / params.GPI_Km_G6P + F6P / params.GPI_Km_F6P)
    )
    return Rate
end

function rate_13C_PFKP(F6P_13C, F16BP_13C, F6P, ATP, F16BP, ADP, Phosphate, Citrate, F26BP, params)
    Z_a_cat = (
        1 +
        (F6P / params.PFKP_K_a_F6P) +
        (ATP / params.PFKP_K_ATP) +
        (F16BP / params.PFKP_K_F16BP) +
        (ADP / params.PFKP_K_ADP) +
        (F6P / params.PFKP_K_a_F6P) * (ATP / params.PFKP_K_ATP) +
        (F16BP / params.PFKP_K_F16BP) * (ADP / params.PFKP_K_ADP)
    )
    Z_i_cat = (
        1 +
        (ATP / params.PFKP_K_ATP) +
        (F16BP / params.PFKP_K_F16BP) +
        (ADP / params.PFKP_K_ADP) +
        (F16BP / params.PFKP_K_F16BP) * (ADP / params.PFKP_K_ADP)
    )
    Z_a_reg = (
        (1 + Phosphate / params.PFKP_K_Phosphate) *
        (1 + ADP / params.PFKP_K_a_ADP_reg) *
        (1 + F26BP / params.PFKP_K_a_F26BP)
    )
    Z_i_reg = (
        (1 + ATP / params.PFKP_K_i_ATP_reg + Phosphate / params.PFKP_K_Phosphate) *
        (1 + F26BP / params.PFKP_K_i_F26BP) *
        (1 + Citrate / params.PFKP_K_i_Citrate)
    )

    Rate =
        params.PFKP_Vmax *
        params.PFKP_Conc *
        (ATP * F6P_13C - ADP * F16BP_13C / params.PFKP_Keq) *
        (1 / params.PFKP_K_a_F6P) *
        (1 / params.PFKP_K_ATP) *
        (Z_a_cat^3) *
        (Z_a_reg^4) / ((Z_a_cat^4) * (Z_a_reg^4) + params.PFKP_L * (Z_i_cat^4) * (Z_i_reg^4))
    return Rate
end

function rate_13C_ALDO(F16BP_13C, GAP_13C, DHAP_13C, F16BP, GAP, DHAP, params)
    Rate = (
        (params.ALDO_Vmax * params.ALDO_Conc / params.ALDO_Km_F16BP) * (
            (F16BP_13C - (1 / params.ALDO_Keq) * (DHAP_13C * GAP_13C)) / (
                1 +
                GAP * DHAP / (params.ALDO_Kd_DHAP * params.ALDO_Km_GAP) +
                DHAP / params.ALDO_Kd_DHAP +
                F16BP * GAP / (params.ALDO_Ki_GAP * params.ALDO_Km_F16BP) +
                F16BP / params.ALDO_Km_F16BP +
                GAP * params.ALDO_Km_DHAP / (params.ALDO_Kd_DHAP * params.ALDO_Km_GAP)
            )
        )
    )
    return Rate
end

function rate_13C_TPI(GAP_13C, DHAP_13C, GAP, DHAP, params)
    Rate = (
        (params.TPI_Vmax * params.TPI_Conc / params.TPI_Km_DHAP) *
        (DHAP_13C - (1 / params.TPI_Keq) * GAP_13C) /
        (1 + (DHAP / params.TPI_Km_DHAP) + (GAP / params.TPI_Km_GAP))
    )
    return Rate
end

function rate_13C_GAPDH(GAP_13C, BPG_13C, GAP, NAD, Phosphate, BPG, NADH, params)
    Z_a =
        (
            1 +
            GAP / params.GAPDH_K_GAP * (1 + Phosphate / params.GAPDH_K_a_Phosphate) +
            BPG / params.GAPDH_K_BPG
        ) * (1 + NAD / params.GAPDH_K_a_NAD + NADH / params.GAPDH_K_a_NADH)

    Z_i =
        (1 + NAD / params.GAPDH_K_i_NAD) * (
            1 +
            GAP / params.GAPDH_K_GAP * (1 + Phosphate / params.GAPDH_K_i_Phosphate) +
            BPG / params.GAPDH_K_BPG
        ) +
        NADH / params.GAPDH_K_i_NADH * (
            1 +
            GAP / params.GAPDH_K_GAP * (1 + Phosphate / params.GAPDH_K_i_Phosphate) +
            BPG / (params.GAPDH_α_i_BPG * params.GAPDH_K_BPG)
        )
    Rate = (
        (
            params.GAPDH_Vmax * params.GAPDH_Conc /
            (params.GAPDH_K_GAP * params.GAPDH_K_a_NAD * params.GAPDH_K_a_Phosphate)
        ) *
        Z_a^3 *
        (GAP_13C * NAD * Phosphate - (1 / params.GAPDH_Keq) * BPG_13C * NADH) /
        (Z_a^4 + params.GAPDH_L * Z_i^4)
    )
    return Rate
end

function rate_13C_PGK(BPG_13C, ThreePG_13C, BPG, ADP, ATP, ThreePG, params)
    Rate = (
        (params.PGK_Vmax * params.PGK_Conc / (params.PGK_α * params.PGK_K_BPG * params.PGK_K_ADP)) *
        (BPG_13C * ADP - (1 / params.PGK_Keq) * (ThreePG_13C * ATP)) / (
            1 +
            BPG / params.PGK_K_BPG +
            ADP / params.PGK_K_ADP +
            ThreePG / params.PGK_K_ThreePG +
            ATP / params.PGK_K_ATP +
            BPG * ADP / (params.PGK_α * params.PGK_K_BPG * params.PGK_K_ADP) +
            ThreePG * ATP / (params.PGK_β * params.PGK_K_ThreePG * params.PGK_K_ATP) +
            ThreePG * ADP / (params.PGK_γ * params.PGK_K_ThreePG * params.PGK_K_ADP)
        )
    )
    return Rate
end

function rate_13C_PGM(ThreePG_13C, TwoPG_13C, ThreePG, TwoPG, params)
    Rate = (
        (params.PGM_Vmax * params.PGM_Conc / params.PGM_Km_ThreePG) *
        (ThreePG_13C - (1 / params.PGM_Keq) * TwoPG_13C) /
        (1 + ThreePG / params.PGM_Km_ThreePG + TwoPG / params.PGM_Km_TwoPG)
    )
    return Rate
end

function rate_13C_ENO(TwoPG_13C, PEP_13C, TwoPG, PEP, params)
    Rate = (
        (params.ENO_Vmax * params.ENO_Conc / params.ENO_Km_TwoPG) *
        (TwoPG_13C - (1 / params.ENO_Keq) * PEP_13C) /
        (1 + TwoPG / params.ENO_Km_TwoPG + PEP / params.ENO_Km_PEP)
    )
    return Rate
end

function rate_13C_PKM2(PEP_13C, Pyruvate_13C, PEP, ADP, F16BP, ATP, Pyruvate, params)
    Z = (
        ((1 + PEP / params.PKM2_a_KmPEP)^params.PKM2_n) *
        ((1 + ADP / params.PKM2_a_KmADP + ATP / params.PKM2_a_KdATP)^params.PKM2_n) *
        ((1 + F16BP / params.PKM2_a_KdF16BP)^params.PKM2_n) +
        params.PKM2_L *
        ((1 + PEP / params.PKM2_i_KmPEP)^params.PKM2_n) *
        ((1 + ADP / params.PKM2_i_KmADP + ATP / params.PKM2_i_KdATP)^params.PKM2_n) *
        ((1 + F16BP / params.PKM2_i_KdF16BP)^params.PKM2_n)
    )
    Pa = (
        params.PKM2_n *
        (1 / params.PKM2_a_KmPEP) *
        (1 / params.PKM2_a_KmADP) *
        ((1 + PEP / params.PKM2_a_KmPEP)^(params.PKM2_n - 1)) *
        ((1 + ADP / params.PKM2_a_KmADP + ATP / params.PKM2_a_KdATP)^(params.PKM2_n - 1)) *
        ((1 + F16BP / params.PKM2_a_KdF16BP)^params.PKM2_n) / Z
    )
    Pi = (
        params.PKM2_n *
        params.PKM2_L *
        (1 / params.PKM2_i_KmPEP) *
        (1 / params.PKM2_i_KmADP) *
        ((1 + PEP / params.PKM2_i_KmPEP)^(params.PKM2_n - 1)) *
        ((1 + ADP / params.PKM2_i_KmADP + ATP / params.PKM2_i_KdATP)^(params.PKM2_n - 1)) *
        ((1 + F16BP / params.PKM2_i_KdF16BP)^params.PKM2_n) / Z
    )
    Rate = (
        (1 / params.PKM2_n) *
        (params.PKM2_a_Vmax * params.PKM2_Conc * Pa + params.PKM2_i_Vmax * params.PKM2_Conc * Pi) *
        (ADP * PEP_13C - ATP * Pyruvate_13C / params.PKM2_Keq)
    )
    return Rate
end

function rate_13C_LDH(Pyruvate_13C, Lactate_13C, Pyruvate, NADH, NAD, Lactate, params)
    Rate = (
        (params.LDH_Vmax * params.LDH_Conc / (params.LDH_Km_Pyruvate * params.LDH_Kd_NADH)) *
        (Pyruvate_13C * NADH - (1 / params.LDH_Keq) * (Lactate_13C * NAD)) / (
            1 +
            Pyruvate * params.LDH_Km_NADH / (params.LDH_Kd_NADH * params.LDH_Km_Pyruvate) +
            Lactate * params.LDH_Km_NAD / (params.LDH_Kd_NAD * params.LDH_Km_Lactate) +
            NADH / params.LDH_Kd_NADH +
            Lactate * NAD / (params.LDH_Kd_NAD * params.LDH_Km_Lactate) +
            Lactate * NADH * params.LDH_Km_NAD /
            (params.LDH_Kd_NAD * params.LDH_Kd_NADH * params.LDH_Km_Lactate) +
            Pyruvate * NADH / (params.LDH_Kd_NADH * params.LDH_Km_Pyruvate) +
            NAD / params.LDH_Kd_NAD +
            Pyruvate * NAD * params.LDH_Km_NADH /
            (params.LDH_Kd_NAD * params.LDH_Kd_NADH * params.LDH_Km_Pyruvate)
        )
    )
    return Rate
end

function rate_13C_MCT(Lactate_13C, Lactate_media_13C, Lactate, Lactate_media, params)
    Rate = (
        (params.MCT_Vmax * params.MCT_Conc / params.MCT_Km_Lactate) *
        (Lactate_13C - (1 / params.MCT_Keq) * Lactate_media_13C) /
        (1 + Lactate / params.MCT_Km_Lactate + Lactate_media / params.MCT_Km_Lactate)
    )
    return Rate
end