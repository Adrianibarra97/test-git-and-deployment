public class GH_Account_TriggerHandler extends TriggerHandler {
    private List<Account> newRecords;
	private List<Account> oldRecords;
	private Map<Id, Account> newRecordsMap;
	private Map<Id, Account> oldRecordsMap;

    /**
	 * @description Constructor using passed-in class name constructor for faster performance
	 * @param className The name of this class. Pass in the string to make the handler run faster
	 */
	public GH_Account_TriggerHandler(String className) {
		this.newRecords = (List<Account>) Trigger.new;
		this.oldRecords = (List<Account>) Trigger.old;
		this.newRecordsMap = (Map<Id, Account>) Trigger.newMap;
		this.oldRecordsMap = (Map<Id, Account>) Trigger.oldMap;
	}

    public override void beforeUpdate() {
        this.newRecordsMap = GH_CamposPorcentajes_Service.calculaPorcentaje(this.newRecordsMap);
	}

    
}