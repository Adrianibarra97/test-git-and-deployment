public with sharing class GH_CalculoProductividad_Service {

    public static void updateProductividad(List<GH_Rol_De_Guardias__c> lstRolGuardias){
        List<Id> lstIdUH = new List<Id>();
        List<String> lstEspecialidades = new List<String>();
        List<String> lstCurp = new List<String>();
        List<Id> lstIdAcc = new List<Id>();
        for (GH_Rol_De_Guardias__c oRolGuardias : lstRolGuardias) {
            lstIdUH.add(oRolGuardias.GH_lkp_Unidad_Hospitalaria__c);
            if (oRolGuardias.GH_mpl_Especialidad__c.contains(';')) {
                lstEspecialidades.addAll(oRolGuardias.GH_mpl_Especialidad__c.split(';'));
            } else {
                lstEspecialidades.add(oRolGuardias.GH_mpl_Especialidad__c);
            }
        }
        List<Account> lstAcc = [SELECT Id, GH_txt_CURP__c, GH_ccy_Productividad_Importe__c, GH_nbr_Productividad_Volumen__c, GH_pct_Efectividad_Guardia__c
                                FROM Account WHERE GH_pkl_EstadodelMedico__c = 'Activo' AND GH_pkl_EstadodePrivilegios__c = 'Con Privilegios' AND
                                Id IN (SELECT GH_Master_Cuenta__c FROM GH_Especialidad__c WHERE 
                                    GH_pkl_Especialidad__c IN: lstEspecialidades AND GH_ckb_Disponible_Guardia__c = TRUE) AND 
                                Id IN (SELECT GH_Master_Medico__c FROM GH_Asignacion_de_Medicos_a_UH__c WHERE GH_Master_UH__c IN: lstIdUH)];
        for (Account oAcc : lstAcc) {
            lstCurp.add(oAcc.GH_txt_CURP__c);
            lstIdAcc.add(oAcc.Id);
        }
        Map<String, Decimal> mapCurpImporte = getImportes(lstCurp);
        Map<String, Integer> mapCurpVolumen = getVolumen(lstCurp);
        Map<Id, Id> mapUnidadRol = getUltimoRolXUnidad(lstIdUH);
        Map<Id,Double> mapEfectividad = getEfectividad(mapUnidadRol.values(), lstIdAcc);

        for (Account oAcc : lstAcc) {
            oAcc.GH_ccy_Productividad_Importe__c = mapCurpImporte.containsKey(oAcc.GH_txt_CURP__c) ? mapCurpImporte.get(oAcc.GH_txt_CURP__c) : 0;
            oAcc.GH_nbr_Productividad_Volumen__c = mapCurpVolumen.containsKey(oAcc.GH_txt_CURP__c) ? mapCurpVolumen.get(oAcc.GH_txt_CURP__c) : 0;
            oAcc.GH_pct_Efectividad_Guardia__c = mapEfectividad.containsKey(oAcc.Id) ? mapEfectividad.get(oAcc.Id) : 100;
        }

        Database.update(lstAcc, false);
    }
    

    public static Map<String, Decimal> getImportes(List<String> lstCurp) {
        Map<String, Decimal> mapCurpImporte = new Map<String, Decimal>();
        AggregateResult[] groupedResults = [SELECT GH_txt_IdMedico__c , SUM(GH_ccy_ImporteTotal__c)Importe FROM GH_Episodio__c 
                                            WHERE GH_txt_IdMedico__c IN: lstCurp AND CreatedDate = LAST_N_DAYS:30 GROUP BY GH_txt_IdMedico__c];
        for (AggregateResult ar : groupedResults) {
            mapCurpImporte.put((String)ar.get('GH_txt_IdMedico__c'), (Decimal)ar.get('Importe'));
        }
        return mapCurpImporte;
    }
    
    public static Map<String, Integer> getVolumen(List<String> lstCurp) {
        Map<String, Integer> mapCurpImporte = new Map<String, Integer>();
        AggregateResult[] groupedResults = [SELECT GH_txt_IdMedico__c , COUNT(GH_ccy_ImporteTotal__c)Volumen FROM GH_Episodio__c 
                                            WHERE GH_txt_IdMedico__c IN: lstCurp AND CreatedDate = LAST_N_DAYS:30 GROUP BY GH_txt_IdMedico__c];
        for (AggregateResult ar : groupedResults) {
            mapCurpImporte.put((String)ar.get('GH_txt_IdMedico__c'), (Integer)ar.get('Volumen'));
        }
        return mapCurpImporte;
    }
    
    public static Map<Id,Id> getUltimoRolXUnidad(List<Id> lstUnidades) {
        Map<Id, Id> mapUnidadRol = new Map<Id, Id>();
        List<GH_Unidad_Hospitalaria__c> lstUnidadGuardia = [SELECT Id, Name, 
                                                            (SELECT Id, Name, GH_dte_Fecha_Fin_Guardia__c FROM Roles_de_Guardias__r 
                                                                WHERE GH_dte_Fecha_Fin_Guardia__c < TODAY ORDER BY GH_dte_Fecha_Fin_Guardia__c DESC LIMIT 1) 
                                                            FROM GH_Unidad_Hospitalaria__c WHERE Id IN: lstUnidades];
        for (GH_Unidad_Hospitalaria__c oUnidad : lstUnidadGuardia) {
            if (oUnidad.Roles_de_Guardias__r!= null &&!oUnidad.Roles_de_Guardias__r.isEmpty()) {
                mapUnidadRol.put(oUnidad.Id, oUnidad.Roles_de_Guardias__r[0].Id);
            }
        }
        return  mapUnidadRol;
    }

    public static Map<Id,Double> getEfectividad(List<Id> lstRoles, List<Id> lstAcc) {
        Map<Id,Double> mapEfectividad = new Map<Id,Double>();
        AggregateResult[] groupedResults = [SELECT GH_lkp_Medico__c, COUNT(Id)Llamados, SUM(GH_fla_Puntaje__c)Puntos FROM GH_Llamado__c 
                                            WHERE GH_atn_Tipo_de_Llamado__c != 'Llamado -Tipo 4 (Extemporáneo)' AND 
                                            GH_lkp_Guardia_medico__r.GH_lkp_Rol_de_Guardias__c IN: lstRoles AND
                                            GH_lkp_Medico__c IN: lstAcc GROUP BY GH_lkp_Medico__c];
        for (AggregateResult ar : groupedResults) {
            Double efectividad = ((Double)ar.get('Puntos') * 100) / (Double)ar.get('Llamados');
            mapEfectividad.put((Id)ar.get('GH_lkp_Medico__c'), efectividad);
        }
        return mapEfectividad;
    }
}