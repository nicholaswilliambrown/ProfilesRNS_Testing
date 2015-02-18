using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using OpenQA.Selenium;
using OpenQA.Selenium.Firefox;

// Requires reference to WebDriver.Support.dll
using OpenQA.Selenium.Support.UI;
using System.Data.SqlClient;
using System.Data;
using System.IO;

namespace SeleniumTests
{
    class getPageSource
    {
        public static void get(IWebDriver driver)
        {
            personSearch(driver);
            everythingSearch(driver);
            personAndNetworks(driver);
            editPages(driver);
        }

        private static void personSearch(IWebDriver driver)
        {
            driver.Navigate().GoToUrl(Config.URL);
            File.WriteAllText(Config.fileDir + "SearchPage.html", driver.PageSource);

            {
                IWebElement textbox = driver.FindElement(By.Name("ctl00$rptMain$ctl00$ctl00$txtSearchFor"));
                textbox.SendKeys("Adult");
                textbox.Submit();
            }

            File.WriteAllText(Config.fileDir + "People Search Results.html", driver.PageSource);

            driver.FindElements(By.LinkText("Why?")).First().Click();
            File.WriteAllText(Config.fileDir + "People Search Results Why.html", driver.PageSource);
            driver.FindElement(By.PartialLinkText("Back to Search Results")).Click();

            driver.FindElement(By.PartialLinkText("Search Other Institutions")).Click();
            File.WriteAllText(Config.fileDir + "Direct Search.html", driver.PageSource);
            driver.FindElement(By.PartialLinkText("Back to Local Search")).Click();

        }

        private static void everythingSearch(IWebDriver driver)
        {
            driver.Navigate().GoToUrl(Config.URL);
            driver.FindElement(By.LinkText("Find Everything")).Click();
            File.WriteAllText(Config.fileDir + "Search Everything Page.html", driver.PageSource);

            {
                IWebElement textbox = driver.FindElement(By.Name("ctl00$rptMain$ctl00$ctl00$searchfor"));
                textbox.SendKeys("Adult");
                IWebElement submitButton = driver.FindElement(By.XPath("//a[starts-with(@href, 'JavaScript:submitEverythingSearch();')]"));
                submitButton.Click();
            }

            File.WriteAllText(Config.fileDir + "Everything Search Results.html", driver.PageSource);

            driver.FindElement(By.LinkText("People")).Click();
            driver.FindElements(By.LinkText("Why?")).First().Click();
            File.WriteAllText(Config.fileDir + "Everything Search Results Why.html", driver.PageSource);
            driver.FindElement(By.PartialLinkText("Back to Search Results")).Click();

            driver.FindElement(By.LinkText("Research")).Click();
            driver.FindElements(By.LinkText("Academic Article")).First().Click();
            File.WriteAllText(Config.fileDir + "Publication profile.html", driver.PageSource);
            driver.Navigate().Back();

            driver.FindElement(By.LinkText("Concepts")).Click();
            driver.FindElements(By.LinkText("Concept")).First().Click();
            File.WriteAllText(Config.fileDir + "Concept Profile.html", driver.PageSource);
            driver.FindElement(By.LinkText("click here.")).Click();
            File.WriteAllText(Config.fileDir + "Concept Profile Timeline text.html", driver.PageSource);
            driver.FindElements(By.LinkText("Details")).First().Click();
            driver.FindElements(By.LinkText("More General Concepts")).First().Click();
            driver.FindElements(By.LinkText("Related Concepts")).First().Click();
            driver.FindElements(By.LinkText("More Specific Concepts")).First().Click();
            driver.FindElements(By.LinkText("Most Recent")).First().Click();

        }

        private static void personAndNetworks(IWebDriver driver)
        {
            driver.Navigate().GoToUrl(Config.URL);
            driver.FindElement(By.LinkText("Find Everything")).Click();

            {
                IWebElement textbox = driver.FindElement(By.Name("ctl00$rptMain$ctl00$ctl00$searchfor"));
                textbox.SendKeys("Adult");
                IWebElement submitButton = driver.FindElement(By.XPath("//a[starts-with(@href, 'JavaScript:submitEverythingSearch();')]"));
                submitButton.Click();
            }
            driver.FindElement(By.LinkText("People")).Click();
            driver.FindElements(By.LinkText("Person")).First().Click();
            File.WriteAllText(Config.fileDir + "Researcher Profile.html", driver.PageSource);

            driver.FindElement(By.LinkText("Timeline")).Click();
            File.WriteAllText(Config.fileDir + "Researcher Profile Timeline.html", driver.PageSource);


            driver.FindElement(By.LinkText("click here.")).Click();
            File.WriteAllText(Config.fileDir + "Researcher Profile Timeline text.html", driver.PageSource);

            //string personURL = driver.Url;

            driver.FindElements(By.PartialLinkText("See all (")).First().Click();
            File.WriteAllText(Config.fileDir + "Concept cloud.html", driver.PageSource);

            driver.FindElement(By.XPath("//a[contains(@href, '/network/researchareas/categories')]")).Click();
            File.WriteAllText(Config.fileDir + "Concept Categories.html", driver.PageSource);

            driver.FindElement(By.XPath("//a[contains(@href, '/network/researchareas/timeline')]")).Click();
            File.WriteAllText(Config.fileDir + "Concept Timeline.html", driver.PageSource);

            driver.FindElement(By.XPath("//a[contains(@href, '/network/researchareas/details')]")).Click();
            File.WriteAllText(Config.fileDir + "Concept Details.html", driver.PageSource);

            driver.FindElement(By.PartialLinkText("Back to Profile")).Click();

            driver.FindElements(By.PartialLinkText("See all (")).ElementAt(1).Click();
            File.WriteAllText(Config.fileDir + "Co-Author List.html", driver.PageSource);

            driver.FindElement(By.XPath("//a[contains(@href, '/network/coauthors/map')]")).Click();
            File.WriteAllText(Config.fileDir + "Co-Author Map.html", driver.PageSource);

            driver.FindElement(By.LinkText("click here.")).Click();
            File.WriteAllText(Config.fileDir + "Co-Author Map Text.html", driver.PageSource);

            driver.FindElement(By.XPath("//a[contains(@href, '/network/coauthors/radial')]")).Click();
            File.WriteAllText(Config.fileDir + "Co-Author Radial.html", driver.PageSource);

            driver.FindElement(By.LinkText("click here.")).Click();
            File.WriteAllText(Config.fileDir + "Co-Author Radial Text.html", driver.PageSource);

            driver.FindElement(By.XPath("//a[contains(@href, '/network/coauthors/timeline')]")).Click();
            File.WriteAllText(Config.fileDir + "Co-Author Timeline.html", driver.PageSource);

            driver.FindElement(By.XPath("//a[contains(@href, '/network/coauthors/cluster')]")).Click();
            driver.FindElement(By.PartialLinkText("Continue to Cluster View")).Click();
            File.WriteAllText(Config.fileDir + "Co-Author Cluster.html", driver.PageSource);

            driver.FindElement(By.LinkText("click here.")).Click();
            File.WriteAllText(Config.fileDir + "Co-Author Cluster Text.html", driver.PageSource);

            driver.FindElement(By.XPath("//a[contains(@href, '/network/coauthors/details')]")).Click();
            File.WriteAllText(Config.fileDir + "Co-Author Details.html", driver.PageSource);

            driver.FindElement(By.PartialLinkText("Back to Profile")).Click();

            driver.FindElements(By.PartialLinkText("See all (")).ElementAt(2).Click();
            File.WriteAllText(Config.fileDir + "Similar List.html", driver.PageSource);

            driver.FindElement(By.XPath("//a[contains(@href, '/network/similarto/map')]")).Click();
            File.WriteAllText(Config.fileDir + "Similar Map.html", driver.PageSource);

            driver.FindElement(By.LinkText("click here.")).Click();
            File.WriteAllText(Config.fileDir + "Similar Map Text.html", driver.PageSource);

            driver.FindElement(By.XPath("//a[contains(@href, '/network/similarto/details')]")).Click();
            File.WriteAllText(Config.fileDir + "Similar Details.html", driver.PageSource);

        }

        private static void editPages(IWebDriver driver)
        {
            Utilities.logout(driver);
            driver.FindElement(By.LinkText("Login to Profiles")).Click();
            File.WriteAllText(Config.fileDir + "Login.html", driver.PageSource);

            Utilities.gotoEditPage(driver);
            File.WriteAllText(Config.fileDir + "Edit.html", driver.PageSource);

            driver.FindElement(By.LinkText("mailing address")).Click();
            File.WriteAllText(Config.fileDir + "Edit Mailing Address.html", driver.PageSource);
            driver.FindElement(By.PartialLinkText("Edit Visibility")).Click();
            File.WriteAllText(Config.fileDir + "Edit Visibility.html", driver.PageSource);
            driver.FindElement(By.LinkText("Edit My Profile")).Click();

            driver.FindElement(By.LinkText("email address")).Click();
            File.WriteAllText(Config.fileDir + "Edit Email Address.html", driver.PageSource);
            driver.FindElement(By.LinkText("Edit My Profile")).Click();

            driver.FindElement(By.LinkText("photo")).Click();
            driver.FindElement(By.PartialLinkText("Edit Custom Photo")).Click();
            File.WriteAllText(Config.fileDir + "Edit Photo.html", driver.PageSource);
            driver.FindElement(By.LinkText("Edit My Profile")).Click();

            driver.FindElement(By.LinkText("awards and honors")).Click();
            driver.FindElement(By.PartialLinkText("Add award(s)")).Click();
            File.WriteAllText(Config.fileDir + "Edit Awards.html", driver.PageSource);
            driver.FindElement(By.XPath("//input[contains(@id, 'txtStartYear')]")).SendKeys("2000");
            driver.FindElement(By.XPath("//input[contains(@id, 'txtEndYear')]")).SendKeys("2004");
            driver.FindElement(By.XPath("//input[contains(@id, 'txtAwardName')]")).SendKeys("Test award");
            driver.FindElement(By.XPath("//input[contains(@id, 'txtInstitution')]")).SendKeys("Test institution");
            driver.FindElement(By.LinkText("Save and Close")).Click();
            File.WriteAllText(Config.fileDir + "Edit Awards2.html", driver.PageSource);

            driver.FindElement(By.XPath("//input[contains(@id, 'lnkEdit')]")).Click();
            File.WriteAllText(Config.fileDir + "Edit Awards3.html", driver.PageSource);

            driver.FindElement(By.XPath("//input[contains(@id, 'lnkCancel')]")).Click();
            driver.FindElement(By.XPath("//input[contains(@id, 'lnkDelete')]")).Click();
            driver.SwitchTo().Alert().Accept();
            driver.FindElement(By.LinkText("Edit My Profile")).Click();

            driver.FindElement(By.LinkText("overview")).Click();
            driver.FindElement(By.Id("ctl00_rptMain_ctl00_ctl00_ctl00_btnEditProperty")).Click();
            String overviewText = "Hello world this is an overview!!!\nIt was automatically entered by selenium.";
            driver.FindElement(By.Name("ctl00$rptMain$ctl00$ctl00$ctl00$txtLabel")).SendKeys(overviewText);
            File.WriteAllText(Config.fileDir + "Edit Overview.html", driver.PageSource);
            driver.FindElement(By.Id("ctl00_rptMain_ctl00_ctl00_ctl00_btnInsertProperty2")).Click();

            File.WriteAllText(Config.fileDir + "Edit Overview2.html", driver.PageSource);
            driver.FindElement(By.XPath("//input[contains(@id, 'lnkEdit')]")).Click();
            File.WriteAllText(Config.fileDir + "Edit Overview3.html", driver.PageSource);

            driver.FindElement(By.XPath("//input[contains(@id, 'lnkCancel')]")).Click();

            driver.FindElement(By.Id("ctl00_rptMain_ctl00_ctl00_ctl00_GridViewProperty_ctl02_lnkDelete")).Click();
            driver.SwitchTo().Alert().Accept();
            driver.FindElement(By.LinkText("Edit My Profile")).Click();

            driver.FindElement(By.LinkText("selected publications")).Click();
            driver.FindElement(By.PartialLinkText("Add PubMed")).Click();
            File.WriteAllText(Config.fileDir + "Edit Publications.html", driver.PageSource);
            driver.FindElement(By.LinkText("Close")).Click();
            driver.FindElement(By.PartialLinkText("Add by ID")).Click();
            File.WriteAllText(Config.fileDir + "Edit Publications1.html", driver.PageSource);
            driver.FindElement(By.XPath("//input[contains(@id, 'lnkCancel')]")).Click();
            driver.FindElement(By.PartialLinkText("Add Custom")).Click();
            SelectElement select = new SelectElement(driver.FindElement(By.XPath("//select[contains(@id, 'drpPublicationType')]")));
            select.SelectByText("Books/Monographs/Textbooks");
            File.WriteAllText(Config.fileDir + "Edit Publications2.html", driver.PageSource);
            driver.FindElement(By.LinkText("Cancel")).Click();
            driver.FindElement(By.PartialLinkText("Delete")).Click();
            File.WriteAllText(Config.fileDir + "Edit Publications3.html", driver.PageSource);
            driver.FindElement(By.LinkText("Close")).Click();
            driver.FindElement(By.LinkText("Edit My Profile")).Click();

            driver.FindElement(By.LinkText("Manage Proxies")).Click();
            File.WriteAllText(Config.fileDir + "Manage Proxies.html", driver.PageSource);
            driver.FindElement(By.LinkText("Add A Proxy")).Click();
            File.WriteAllText(Config.fileDir + "Manage Proxies Add.html", driver.PageSource);

            Utilities.logout(driver);
        }
    }
}
