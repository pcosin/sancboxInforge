@isTest
private class ChatGPTCampaignTest {

    @IsTest
    public static void testSendChatGPTCallout() {
        // Create a Campaign
        Campaign campaign = new Campaign();
        campaign.Name = 'Test Campaign';
        campaign.IsActive = true;
        campaign.StartDate = Date.today();
        campaign.EndDate = Date.today().addDays(30);
        insert campaign;

        // Create some Leads for testing CampaignMembers
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            Lead lead = new Lead();
            lead.FirstName = 'Lead' + i;
            lead.LastName = 'Test' + i;
            lead.Company = 'Test Company ' + i; 
            leads.add(lead);
        }
        insert leads;

        // Create CampaignMembers and associate them with the Campaign
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        for (Lead lead : leads) {
            CampaignMember campaignMember = new CampaignMember();
            campaignMember.CampaignId = campaign.Id;
            campaignMember.LeadId = lead.Id;
            campaignMember.Status = 'Responded'; // You can set the desired status
            campaignMembers.add(campaignMember);
        }
        insert campaignMembers;

        // You can add additional assertions or test the behavior based on the Campaign and CampaignMembers data here.
        // For example, you can query the inserted Campaign and CampaignMembers to verify the data.
        // Example:
        Campaign insertedCampaign = [SELECT Id, Name, IsActive, StartDate, EndDate FROM Campaign WHERE Id = :campaign.Id];
        System.assertEquals('Test Campaign', insertedCampaign.Name);

        // Set up the mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"choices":[{"text":"Test response"}]}');

        // Mock the HTTP callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        List<ChatGPTCampaignInvokable.InputVariables> inputs = new List<ChatGPTCampaignInvokable.InputVariables>();
        ChatGPTCampaignInvokable.InputVariables input = new ChatGPTCampaignInvokable.InputVariables();
        input.recordId = insertedCampaign.Id;
        input.prompt = 'Test template';
        inputs.add(input);

        // Call the method to be tested
        ChatGPTCampaignInvokable.generateChatGPTEmails(inputs);
        Test.stopTest();

    }

    // Mock HTTP callout class
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;

        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }

        public HttpResponse respond(HttpRequest request) {
            return response;
        }
    }
}