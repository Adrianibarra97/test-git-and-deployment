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
private class GH_Account_TriggerHandler_test {

    @isTest
    static void updateAccount() {
        Account oAcc = new Account();
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('GH_PAc_CredencializacionInicial').getRecordTypeId();
        oAcc.FirstName = 'PUBLICO';
        oAcc.LastName = 'GENERAL';
        oAcc.RecordTypeId = rtId;
        oAcc.GH_pkl_EstadodelMedico__c = 'Activo';
        oAcc.GH_pkl_EstadodePrivilegios__c = 'Con Privilegios';
        oAcc.GH_dte_FechaTerminoCredencializacion__c = date.valueOf('3027-11-30');
        oAcc.GH_pkl_Origen__c = 'Permanente';
        oAcc.GH_pkl_Estatus__c = 'Aprobado';
        insert oAcc;
        oAcc.LastName = 'GENERALL';
        update oAcc;
    }
}