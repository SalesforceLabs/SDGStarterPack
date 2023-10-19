/**
 * @description       :
 * @author            : Stewart Anderson
 * @group             :
 * @last modified on  : 10-18-2023
 * @last modified by  : Stewart Anderson
**/
@isTest
public class SDG_Get_Latest_List_Test {

    @TestSetup
    static void makeData(){

        // Setup Admin User For Test Runs
        String uniqueTimestamp = String.valueOf(System.currentTimeMillis());
        String uniqueUsername = 'admin_sdg_test' + uniqueTimestamp + '@example.com';

        User adminUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'Admin',
            Email = 'admin@example.com',
            Username = uniqueUsername, // Use the unique username
            Alias = 'TestUser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );

        insert adminUser;

        assignPermissions();

        // Setup Parent Goal Object
        sdgsfdev__SDG_Goal__c testGoal = new sdgsfdev__SDG_Goal__c(
            sdgsfdev__Code__c = '1',
            sdgsfdev__Title__c = 'End poverty in all its forms everywhere',
            sdgsfdev__Description__c = 'Goal 1 calls for an end to poverty in all its manifestations, including extreme poverty, over the next 15 years. All people everywhere, including the poorest and most vulnerable, should enjoy a basic standard of living and social protection benefits.'
        );
        insert testGoal;
    }

    @future
    private static void assignPermissions(){
        User testUser = [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        PermissionSet permissionSetTest = [SELECT Id, Name FROM PermissionSet WHERE Name = 'SDG_Admin' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = permissionSetTest.Id);
    }

    // Create a mock HTTP callout response for fetchTargets
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private Boolean throwException;
        private String mockedResponse;

        public MockHttpResponseGenerator() {
            this.throwException = false;
            this.mockedResponse = '';
        }

        public MockHttpResponseGenerator(Boolean throwException, String mockedResponse) {
            this.throwException = throwException;
            this.mockedResponse = mockedResponse;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if (throwException) {
                res.setStatusCode(500); // Simulate an error status code
            } else {
                res.setStatusCode(200);
                // Set the response body for fetchGoals
                if (mockedResponse == 'goals') {
                    System.debug('Returning Goals Data');
                    res.setBody('[{"code":"1","title":"End poverty in all its forms everywhere","description":"Goal 1 calls for an end to poverty in all its manifestations, including extreme poverty, over the next 15 years. All people everywhere, including the poorest and most vulnerable, should enjoy a basic standard of living and social protection benefits.","uri":"/v1/sdg/Goal/1"},{"code":"2","title":"End hunger, achieve food security and improved nutrition and promote sustainable agriculture","description":"Goal 2 seeks to end hunger and all forms of malnutrition and to achieve sustainable food production by 2030. It is premised on the idea that everyone should have access to sufficient nutritious food, which will require widespread promotion of sustainable agriculture, a doubling of agricultural productivity, increased investments and properly functioning food markets.","uri":"/v1/sdg/Goal/2"},{"code":"3","title":"Ensure healthy lives and promote well-being for all at all ages","description":"Goal 3 aims to ensure health and well-being for all at all ages by improving reproductive, maternal and child health; ending the epidemics of major communicable diseases; reducing non-communicable and environmental diseases; achieving universal health coverage; and ensuring access to safe, affordable and effective medicines and vaccines for all.","uri":"/v1/sdg/Goal/3"},{"code":"4","title":"Ensure inclusive and equitable quality education and promote lifelong learning opportunities for all","description":"Goal 4 focuses on the acquisition of foundational and higher-order skills; greater and more equitable access to technical and vocational education and training and higher education; training throughout life; and the knowledge, skills and values needed to function well and contribute to society.","uri":"/v1/sdg/Goal/4"},{"code":"5","title":"Achieve gender equality and empower all women and girls","description":"Goal 5 aims to empower women and girls to reach their full potential, which requires eliminating all forms of discrimination and violence against them, including harmful practices. It seeks to ensure that they have every opportunity for sexual and reproductive health and reproductive rights; receive due recognition for their unpaid work; have full access to productive resources; and enjoy equal participation with men in political, economic and public life.","uri":"/v1/sdg/Goal/5"},{"code":"6","title":"Ensure availability and sustainable management of water and sanitation for all","description":"Goal 6 goes beyond drinking water, sanitation and hygiene to also address the quality and sustainability of water resources. Achieving this Goal, which is critical to the survival of people and the planet, means expanding international cooperation and garnering the support of local communities in improving water and sanitation management.","uri":"/v1/sdg/Goal/6"},{"code":"7","title":"Ensure access to affordable, reliable, sustainable and modern energy for all","description":"Goal 7 seeks to promote broader energy access and increased use of renewable energy, including through enhanced international cooperation and expanded infrastructure and technology for clean energy.","uri":"/v1/sdg/Goal/7"},{"code":"8","title":"Promote sustained, inclusive and sustainable economic growth, full and productive employment and decent work for all","description":"Goal 8 aims to provide opportunities for full and productive employment and decent work for all while eradicating forced labour, human trafficking and child labour.","uri":"/v1/sdg/Goal/8"},{"code":"9","title":"Build resilient infrastructure, promote inclusive and sustainable industrialization and foster innovation","description":"Goal 9 focuses on the promotion of infrastructure development, industrialization and innovation. This can be accomplished through enhanced international and domestic financial, technological and technical support, research and innovation, and increased access to information and communication technology.","uri":"/v1/sdg/Goal/9"},{"code":"10","title":"Reduce inequality within and among countries","description":"Goal 10 calls for reducing inequalities in income, as well as those based on sex, age, disability, race, class, ethnicity, religion and opportunity—both within and among countries. It also aims to ensure safe, orderly and regular migration and addresses issues related to representation of developing countries in global decision-making and development assistance.","uri":"/v1/sdg/Goal/10"},{"code":"11","title":"Make cities and human settlements inclusive, safe, resilient and sustainable","description":"Goal 11 aims to renew and plan cities and other human settlements in a way that fosters community cohesion and personal security while stimulating innovation and employment.","uri":"/v1/sdg/Goal/11"},{"code":"12","title":"Ensure sustainable consumption and production patterns","description":"Goal 12 aims to promote sustainable consumption and production patterns through measures such as specific policies and international agreements on the management of materials that are toxic to the environment.","uri":"/v1/sdg/Goal/12"},{"code":"13","title":"Take urgent action to combat climate change and its impacts","description":"Climate change presents the single biggest threat to development, and its widespread, unprecedented effects disproportionately burden the poorest and the most vulnerable. Urgent action is needed not only to combat climate change and its impacts, but also to build resilience in responding to climate-related hazards and natural disasters.","uri":"/v1/sdg/Goal/13"},{"code":"14","title":"Conserve and sustainably use the oceans, seas and marine resources for sustainable development","description":"Goal 14 seeks to promote the conservation and sustainable use of marine and coastal ecosystems, prevent marine pollution and increase the economic benefits to small island developing States and LDCs from the sustainable use of marine resources.","uri":"/v1/sdg/Goal/14"},{"code":"15","title":"Protect, restore and promote sustainable use of terrestrial ecosystems, sustainably manage forests, combat desertification, and halt and reverse land degradation and halt biodiversity loss","description":"Goal 15 focuses on managing forests sustainably, restoring degraded lands and successfully combating desertification, reducing degraded natural habitats and ending biodiversity loss. All of these efforts in combination will help ensure that livelihoods are preserved for those that depend directly on forests and other ecosystems, that biodiversity will thrive, and that the benefits of these natural resources will be enjoyed for generations to come.","uri":"/v1/sdg/Goal/15"},{"code":"16","title":"Promote peaceful and inclusive societies for sustainable development, provide access to justice for all and build effective, accountable and inclusive institutions at all levels","description":"Goal 16 envisages peaceful and inclusive societies based on respect for human rights, the rule of law, good governance at all levels, and transparent, effective and accountable institutions. Many countries still face protracted violence and armed conflict, and far too many people are poorly supported by weak institutions and lack access to justice, information and other fundamental freedoms.","uri":"/v1/sdg/Goal/16"},{"code":"17","title":"Strengthen the means of implementation and revitalize the Global Partnership for Sustainable Development","description":"The 2030 Agenda requires a revitalized and enhanced global partnership that mobilizes all available resources from Governments, civil society, the private sector, the United Nations system and other actors. Increasing support to developing countries, in particular LDCs, landlocked developing countries and small island developing States is fundamental to equitable progress for all.","uri":"/v1/sdg/Goal/17"}]');
                }
                // Set the response body for fetchTargets
                else if (mockedResponse == 'targets') {
                    System.debug('Returning Targets Data');
                    res.setBody('[{"code":"1","title":"End poverty in all its forms everywhere","description":"Goal 1 calls for an end to poverty in all its manifestations, including extreme poverty, over the next 15 years. All people everywhere, including the poorest and most vulnerable, should enjoy a basic standard of living and social protection benefits.","uri":"/v1/sdg/Goal/1","targets":[{"goal":null,"code":"1.1","title":"By 2030, eradicate extreme poverty for all people everywhere, currently measured as people living on less than $1.25 a day","description":"By 2030, eradicate extreme poverty for all people everywhere, currently measured as people living on less than $1.25 a day","uri":"/v1/Target/1.1","indicators":[{"goal":null,"target":null,"code":"1.1.1","description":"Proportion of the population living below the international poverty line by sex, age, employment status and geographic location (urban/rural)","tier":"1","uri":"/v1/Indicator/1.1.1","series":[]}]},{"goal":null,"code":"1.2","title":"By 2030, reduce at least by half the proportion of men, women and children of all ages living in poverty in all its dimensions according to national definitions","description":"By 2030, reduce at least by half the proportion of men, women and children of all ages living in poverty in all its dimensions according to national definitions","uri":"/v1/Target/1.2","indicators":[{"goal":null,"target":null,"code":"1.2.1","description":"Proportion of population living below the national poverty line, by sex and age","tier":"1","uri":"/v1/Indicator/1.2.1","series":[]},{"goal":null,"target":null,"code":"1.2.2","description":"Proportion of men, women and children of all ages living in poverty in all its dimensions according to national definitions","tier":"2","uri":"/v1/Indicator/1.2.2","series":[]}]},{"goal":null,"code":"1.3","title":"Implement nationally appropriate social protection systems and measures for all, including floors, and by 2030 achieve substantial coverage of the poor and the vulnerable","description":"Implement nationally appropriate social protection systems and measures for all, including floors, and by 2030 achieve substantial coverage of the poor and the vulnerable","uri":"/v1/Target/1.3","indicators":[{"goal":null,"target":null,"code":"1.3.1","description":"Proportion of population covered by social protection floors/systems, by sex, distinguishing children, unemployed persons, older persons, persons with disabilities, pregnant women, newborns, work-injury victims and the poor and the vulnerable","tier":"1","uri":"/v1/Indicator/1.3.1","series":[]}]},{"goal":null,"code":"1.4","title":"By 2030, ensure that all men and women, in particular the poor and the vulnerable, have equal rights to economic resources, as well as access to basic services, ownership and control over land and other forms of property, inheritance, natural resources, appropriate new technology and financial services, including microfinance","description":"By 2030, ensure that all men and women, in particular the poor and the vulnerable, have equal rights to economic resources, as well as access to basic services, ownership and control over land and other forms of property, inheritance, natural resources, appropriate new technology and financial services, including microfinance","uri":"/v1/Target/1.4","indicators":[{"goal":null,"target":null,"code":"1.4.1","description":"Proportion of population living in households with access to basic services","tier":"1","uri":"/v1/Indicator/1.4.1","series":[]},{"goal":null,"target":null,"code":"1.4.2","description":"Proportion of total adult population with secure tenure rights to land, (a) with legally recognized documentation, and (b) who perceive their rights to land as secure, by sex and type of tenure","tier":"2","uri":"/v1/Indicator/1.4.2","series":[]}]},{"goal":null,"code":"1.5","title":"By 2030, build the resilience of the poor and those in vulnerable situations and reduce their exposure and vulnerability to climate-related extreme events and other economic, social and environmental shocks and disasters","description":"By 2030, build the resilience of the poor and those in vulnerable situations and reduce their exposure and vulnerability to climate-related extreme events and other economic, social and environmental shocks and disasters","uri":"/v1/Target/1.5","indicators":[{"goal":null,"target":null,"code":"1.5.1","description":"Number of deaths, missing persons and directly affected persons attributed to disasters per 100,000 population","tier":"1","uri":"/v1/Indicator/1.5.1","series":[]},{"goal":null,"target":null,"code":"1.5.2","description":"Direct economic loss attributed to disasters in relation to global gross domestic product (GDP)","tier":"1","uri":"/v1/Indicator/1.5.2","series":[]},{"goal":null,"target":null,"code":"1.5.3","description":"Number of countries that adopt and implement national disaster risk reduction strategies in line with the Sendai Framework for Disaster Risk Reduction 2015-2030","tier":"1","uri":"/v1/Indicator/1.5.3","series":[]},{"goal":null,"target":null,"code":"1.5.4","description":"Proportion of local governments that adopt and implement local disaster risk reduction strategies in line with national disaster risk reduction strategies","tier":"2","uri":"/v1/Indicator/1.5.4","series":[]}]},{"goal":null,"code":"1.a","title":"Ensure significant mobilization of resources from a variety of sources, including through enhanced development cooperation, in order to provide adequate and predictable means for developing countries, in particular least developed countries, to implement programmes and policies to end poverty in all its dimensions","description":"Ensure significant mobilization of resources from a variety of sources, including through enhanced development cooperation, in order to provide adequate and predictable means for developing countries, in particular least developed countries, to implement programmes and policies to end poverty in all its dimensions","uri":"/v1/Target/1.a","indicators":[{"goal":null,"target":null,"code":"1.a.2","description":"Proportion of total government spending on essential services (education, health and social protection)","tier":"2","uri":"/v1/Indicator/1.a.2","series":[]},{"goal":null,"target":null,"code":"1.a.1","description":"Total official development assistance grants from all donors that focus on poverty reduction as a share of the recipient country’s gross national income","tier":"1","uri":"/v1/Indicator/1.a.1","series":[]}]},{"goal":null,"code":"1.b","title":"Create sound policy frameworks at the national, regional and international levels, based on pro-poor and gender-sensitive development strategies, to support accelerated investment in poverty eradication actions","description":"Create sound policy frameworks at the national, regional and international levels, based on pro-poor and gender-sensitive development strategies, to support accelerated investment in poverty eradication actions","uri":"/v1/Target/1.b","indicators":[{"goal":null,"target":null,"code":"1.b.1","description":"Pro-poor public social spending","tier":"2","uri":"/v1/Indicator/1.b.1","series":[]}]}]}]');
                }
            }
            return res;
        }
    }

    @isTest
    static void testInvocableFetchGoals() {

        User testUser = [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(testUser) {

            Test.startTest();
            List<Boolean> shouldExecuteTrue = new List<Boolean>{true};
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(false, 'goals'));
            List<Boolean> resultTrue = SDG_Get_Latest_List.invocableFetchGoals(shouldExecuteTrue);
            Test.stopTest();

            System.assertEquals(1, resultTrue.size());
            System.assertEquals(true, resultTrue[0]);

        }

    }

    @isTest
    static void testFetchGoalsException() {

        User testUser = [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(testUser) {

            Test.startTest();
            // Test case when an exception is thrown
            List<Boolean> shouldExecuteException = new List<Boolean>{true};
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(true, 'goals'));
            List<Boolean> resultException = SDG_Get_Latest_List.invocableFetchGoals(shouldExecuteException);
            Test.stoptest();

            System.assertEquals(1, resultException.size());
            System.assertEquals(false, resultException[0]);

        }
    }

    @isTest
    static void testFetchTargets() {

        User testUser = [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(testUser) {

            // Create a mock HTTP response to simulate a successful callout for fetchGoals
            Test.startTest();

            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(false, 'targets'));

            // Call the fetchTargets method with the test data
            sdgsfdev__SDG_Goal__c testGoal = [SELECT Id FROM sdgsfdev__SDG_Goal__c WHERE sdgsfdev__Code__c = '1' LIMIT 1];
            SDG_Get_Latest_List.fetchTargets('1', testGoal.Id);

            Test.stopTest();

            List<sdgsfdev__SDG_Goal_Target__c> insertedTargets = [SELECT Id FROM sdgsfdev__SDG_Goal_Target__c WHERE sdgsfdev__Goal__c = :testGoal.Id];
            System.assertEquals(7, insertedTargets.size());
        }

    }
}
