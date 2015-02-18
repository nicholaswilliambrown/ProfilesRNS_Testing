using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Drawing;
using OpenQA.Selenium;
using OpenQA.Selenium.Firefox;

// Requires reference to WebDriver.Support.dll
using OpenQA.Selenium.Support.UI;
using System.Data.SqlClient;
using System.Data;
using System.IO;


namespace SeleniumTests
{
    class Program
    {




        static void Main(string[] args)
        {
            runTests();
        }

        static void runTests()
        {
            IWebDriver driver = new FirefoxDriver();
            driver.Manage().Window.Position = new Point(1920, 0);

            driver.Manage().Timeouts().ImplicitlyWait(TimeSpan.FromSeconds(Config.implicitTimeout));

            // Navigate to the profiles homepage
            driver.Navigate().GoToUrl(Config.URL);

            //loginTest(driver);
            //verifySecurityOptions("http://vivoweb.org/ontology/core#overview", "overview", driver);
            //downloadAllSource(driver);
            getPageSource.get(driver);

            System.Console.WriteLine("Press enter to exit");
            System.Console.ReadLine();
            //Close the browser
            driver.Quit();
        }

        static void adultTest()
        {

            // Create a new instance of the Firefox driver.

            // Notice that the remainder of the code relies on the interface, 
            // not the implementation.

            // Further note that other drivers (InternetExplorerDriver,
            // ChromeDriver, etc.) will require further configuration 
            // before this example will work. See the wiki pages for the
            // individual drivers at http://code.google.com/p/selenium/wiki
            // for further information.
            IWebDriver driver = new FirefoxDriver();

            //Notice navigation is slightly different than the Java version
            //This is because 'get' is a keyword in C#
            driver.Navigate().GoToUrl(Config.URL);

            // Find the text input element by its name
            IWebElement query = driver.FindElement(By.Name("ctl00$rptMain$ctl00$ctl00$txtSearchFor"));




            // Enter something to search for
            query.SendKeys("Adult");
            System.Console.ReadLine();
            // Now submit the form. WebDriver will find the form for us from the element
            query.Submit();

            // Google's search is rendered dynamically with JavaScript.
            // Wait for the page to load, timeout after 10 seconds
            WebDriverWait wait = new WebDriverWait(driver, TimeSpan.FromSeconds(10));
            //wait.Until((d) => { return d.Title.ToLower().StartsWith("cheese"); });

            // Should see: "Cheese - Google Search"
            System.Console.WriteLine("Page title is: " + driver.Title);
            System.Console.ReadLine();
            //Close the browser
            driver.Quit();
        }

        static void loginTest(IWebDriver driver)
        {

            // Create a new instance of the Firefox driver.

            // Notice that the remainder of the code relies on the interface, 
            // not the implementation.

            // Further note that other drivers (InternetExplorerDriver,
            // ChromeDriver, etc.) will require further configuration 
            // before this example will work. See the wiki pages for the
            // individual drivers at http://code.google.com/p/selenium/wiki
            // for further information.


            Utilities.gotoEditPage(driver);

            // Go to the overview page
            driver.FindElement(By.LinkText("overview")).Click();

            // Add an overview
            driver.FindElement(By.Id("ctl00_rptMain_ctl00_ctl00_ctl00_btnEditProperty")).Click();
            String overviewText = "Hello world this is an overview!!!\nIt was automatically entered by selenium.";
            driver.FindElement(By.Name("ctl00$rptMain$ctl00$ctl00$ctl00$txtLabel")).SendKeys(overviewText);
            driver.FindElement(By.Id("ctl00_rptMain_ctl00_ctl00_ctl00_btnInsertProperty2")).Click();
            Thread.Sleep(Config.sleepTime);

            // Go to the view page
            driver.FindElement(By.LinkText("View My Profile")).Click();
            Thread.Sleep(Config.sleepTime);

            if (driver.FindElement(By.Id("http://vivoweb.org/ontology/core#overview")).Text.Equals("Hello world this is an overview!!!\nIt was automatically entered by selenium."))
            {
                System.Console.WriteLine("AAA");
            }

            verifyOverviewInDatabase(Config.personID, overviewText, 0);

            Utilities.gotoEditPage(driver);
            driver.FindElement(By.LinkText("overview")).Click();

            driver.FindElement(By.Id("ctl00_rptMain_ctl00_ctl00_ctl00_GridViewProperty_ctl02_lnkDelete")).Click();
            IAlert alert = driver.SwitchTo().Alert();
            alert.Accept();

        }

        static bool verifySecurityOptions(string property, string propertyLabel, IWebDriver driver)
        {
            Utilities.gotoEditPage(driver);

            // Go to the overview page
            driver.FindElement(By.LinkText(propertyLabel)).Click();

            return false;
        }

        static bool verifyOverviewInDatabase(int personID, string overview, int viewSecurityGroup)
        {
            SqlConnection dbconnection = new SqlConnection(Config.sqlConnectionString);
            SqlCommand dbcommand = new SqlCommand("select i.internalid as personID, n2.value as overview, t.ViewSecurityGroup, t.subject as personNodeID from [RDF.].Triple t " +
                                                        "join [RDF.].Node n1 " +
                                                        "on t.Predicate = n1.NodeID " +
                                                        "and n1.Value = 'http://vivoweb.org/ontology/core#overview' " +
                                                        "join [RDF.].Node n2 " +
                                                        "on t.Object = n2.NodeID " +
                                                        "join [RDF.Stage].InternalNodeMap i " +
                                                        "on i.NodeID = t.Subject " +
                                                        "and i.class = 'http://xmlns.com/foaf/0.1/Person' " +
                                                        "and i.internalid = " + personID);

            SqlDataReader dbreader;
            dbconnection.Open();
            dbcommand.CommandType = CommandType.Text;
            dbcommand.CommandTimeout = Config.commandTimeOut;
            dbcommand.Connection = dbconnection;
            dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection);

            while (dbreader.Read())
            {
                Console.WriteLine(dbreader["PersonID"]);
                Console.WriteLine(dbreader["overview"]);
                Console.WriteLine(dbreader["ViewSecurityGroup"]);
                Console.WriteLine(dbreader["personNodeID"]);

                if (dbreader["overview"].ToString().Equals(overview)) Console.WriteLine("Overview Matches!!!");

            }
            return false;
        }

        static Config.SecurityOptions getViewSecurityGroup(int personID, string property)
        {

            SqlConnection dbconnection = new SqlConnection(Config.sqlConnectionString);
            SqlCommand dbcommand = new SqlCommand("select distinct t.ViewSecurityGroup, t.Subject as personNodeID from [RDF.].Triple t " +
                                                        "join [RDF.].Node n1 " +
                                                        "on t.Predicate = n1.NodeID " +
                                                        "and n1.Value = '" + property + "' " +
                                                        "join [RDF.].Node n2 " +
                                                        "on t.Object = n2.NodeID " +
                                                        "join [RDF.Stage].InternalNodeMap i " +
                                                        "on i.NodeID = t.Subject " +
                                                        "and i.class = 'http://xmlns.com/foaf/0.1/Person' " +
                                                        "and i.internalid = " + personID);

            SqlDataReader dbreader;
            dbconnection.Open();
            dbcommand.CommandType = CommandType.Text;
            dbcommand.CommandTimeout = Config.commandTimeOut;
            dbcommand.Connection = dbconnection;
            dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection);

            if (!dbreader.HasRows) return Config.SecurityOptions.Error;

            dbreader.Read();
            int viewSecurityGroup = Convert.ToInt32(dbreader["ViewSecurityGroup"].ToString());
            int personNodeID = Convert.ToInt32(dbreader["personNodeID"].ToString());

            // Error if there is more than one row
            if (!dbreader.Read()) return Config.SecurityOptions.Error;

            if (viewSecurityGroup == -50) return Config.SecurityOptions.Admins;
            if (viewSecurityGroup == -40) return Config.SecurityOptions.Curators;
            if (viewSecurityGroup == -30) return Config.SecurityOptions.Harvesters;
            if (viewSecurityGroup == -20) return Config.SecurityOptions.Users;
            if (viewSecurityGroup == -10) return Config.SecurityOptions.NoSearch;
            if (viewSecurityGroup == -1) return Config.SecurityOptions.Public;
            if (viewSecurityGroup == getUserNodeIdFromPersonID(personID)) return Config.SecurityOptions.OnlyME;



            return Config.SecurityOptions.Error;
        }

        static int getUserNodeIdFromPersonID(int personID)
        {
            SqlConnection dbconnection = new SqlConnection(Config.sqlConnectionString);
            SqlCommand dbcommand = new SqlCommand("select I.NodeID from [profile.data].person p " + 
                                                    "join [RDF.Stage].[InternalNodeMap] i " +
                                                    "on p.PersonID = " + personID +
                                                    "and p.UserID = i.InternalID " +
                                                    "and i.class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User'");

            SqlDataReader dbreader;
            dbconnection.Open();
            dbcommand.CommandType = CommandType.Text;
            dbcommand.CommandTimeout = Config.commandTimeOut;
            dbcommand.Connection = dbconnection;
            dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection);

            if (!dbreader.HasRows) return -1;

            dbreader.Read();
            return Convert.ToInt32(dbreader["NodeID"].ToString());
        }


    }
}
