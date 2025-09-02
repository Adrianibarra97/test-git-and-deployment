/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class GH_CalculoProductividad_Service_test {

    /**
    * @description Genera datos de prueba
    * @author Jair Ignacio Gonzalez G. | 01-02-2025 
    **/
    @TestSetup static void makeData() {
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'or Name='Administrador del Sistema']; 
        User testUser = new User(  Alias = 'standt', 
                            Email='adminUser' + math.random() + '@test.com',
                            EmailEncodingKey='UTF-8', 
                            LastName='Testing', 
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', 
                            ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles',                                 
                            GH_pkl_UnidadHospitalaria__c = 'Querétaro',
                            UserName = 'guardiastablectrk@testorg.com');
        insert testUser;
        System.runAs(testUser) {
        Account testAccount = new Account(
            Name = 'MEDICO',
        	GH_pkl_EstadodelMedico__c = 'Activo',
            GH_pkl_EstadodePrivilegios__c = 'Con Privilegios'
        );
        insert testAccount;

  		GH_Especialidad__c testSpecialist = new GH_Especialidad__c(
            GH_pkl_Especialidad__c = 'Pediatría',
    		GH_Master_Cuenta__c = testAccount.Id,
            GH_ckb_Disponible_Guardia__c = TRUE
        );
        insert testSpecialist;
        GH_Unidad_Hospitalaria__c oUH = new GH_Unidad_Hospitalaria__c(
            Name ='Querétaro',
            GH_txt_ID_UH_ERP__c='0000'
        );
        insert oUH;
        GH_Asignacion_de_Medicos_a_UH__c asignMed = new GH_Asignacion_de_Medicos_a_UH__c(
            GH_Master_Medico__c = testAccount.Id,
            GH_Master_UH__c = oUH.Id
        );
        insert asignMed;
        GH_Rol_De_Guardias__c testRole = new GH_Rol_De_Guardias__c(
            Name = 'Test Role',
            GH_pkl_Estado__c = 'Draft',
            GH_dte_Fecha_Inicio_Guardia__c=System.today().addDays(1),
            GH_dte_Fecha_Fin_Guardia__c=System.today().addDays(31),
            GH_lkp_Unidad_Hospitalaria__c = oUH.Id,
            GH_nbr_DuracionGuardias__c = 7,
            GH_mpl_Especialidad__c = 'Pediatría'
        );
        insert testRole;

        List<GH_Guardia__c> testGuards = new List<GH_Guardia__c>();
            integer flagstart = 1;
            integer flagend = 8;
        for (Integer i = 0; i <= 5; i++) {
            
            testGuards.add(new GH_Guardia__c(
                Name = 'Guard ' ,
                GH_lkp_Especialidad__c = testSpecialist.Id,
                GH_dtt_FechayHoraDeInicio__c = Date.today().addDays(flagstart),
                GH_dtt_FechayHoradeFin__c = Date.today().addDays((flagend)),
                GH_lkp_Rol_de_Guardias__c = testRole.Id,
                GH_pkl_Especialidad_del__c = 'Pediatría',
                GH_pkl_TipoDeLlamado__c ='Llamado -Tipo 1',
                GH_lkp_Medico__c= testAccount.Id
            ));
            flagstart +=7;
            flagend +=7;
        }
             flagstart = 8;
             flagend = 15;
        for (Integer i = 0; i <= 5; i++) {
            
            testGuards.add(new GH_Guardia__c(
                Name = 'Guard ' ,
                GH_lkp_Especialidad__c = testSpecialist.Id,
                GH_dtt_FechayHoraDeInicio__c = Date.today().addDays(flagstart),
                GH_dtt_FechayHoradeFin__c = Date.today().addDays((flagend)),
                GH_lkp_Rol_de_Guardias__c = testRole.Id,
                GH_pkl_Especialidad_del__c = 'Pediatría',
                GH_pkl_TipoDeLlamado__c ='Llamado -Tipo 2',
                GH_lkp_Medico__c= testAccount.Id
            ));
            flagstart +=0;
            flagend +=7;
        }
        
        insert testGuards;
        }
    }

    @isTest
    static void testUpdateProductividad() {
        GH_Unidad_Hospitalaria__c oUH = [SELECT Id FROM GH_Unidad_Hospitalaria__c WHERE Name ='Querétaro'];
        GH_Rol_De_Guardias__c testRole = new GH_Rol_De_Guardias__c(
            Name = 'Test Role',
            GH_pkl_Estado__c = 'Draft',
            GH_dte_Fecha_Inicio_Guardia__c=System.today().addDays(32),
            GH_dte_Fecha_Fin_Guardia__c=System.today().addDays(61),
            GH_lkp_Unidad_Hospitalaria__c = oUH.Id,
            GH_nbr_DuracionGuardias__c = 7,
            GH_mpl_Especialidad__c = 'Pediatría'
        );
        insert testRole;
    }}