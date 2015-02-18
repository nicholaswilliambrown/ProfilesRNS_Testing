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
    class Utilities
    {

        public static void gotoEditPage(IWebDriver driver)
        {
            // Go to the edit page
            IWebElement editLink = driver.FindElement(By.LinkText("Edit My Profile"));
            editLink.Click();
            if (driver.Url.Contains("login/default.aspx?method=login&edit=true"))
            {
                // Login with the username and password
                driver.FindElement(By.Name("ctl00$rptMain$ctl00$ctl00$txtUserName")).SendKeys(Config.username);
                driver.FindElement(By.Name("ctl00$rptMain$ctl00$ctl00$txtPassword")).SendKeys(Config.password);
                driver.FindElement(By.Name("ctl00$rptMain$ctl00$ctl00$cmdSubmit")).Click();
            }
        }

        public static void logout(IWebDriver driver)
        {
            driver.Manage().Timeouts().ImplicitlyWait(TimeSpan.FromSeconds(0));
            System.Collections.ObjectModel.ReadOnlyCollection<IWebElement> e = driver.FindElements(By.LinkText("Logout"));
            if (e.Count > 0) e.First().Click();
            driver.Manage().Timeouts().ImplicitlyWait(TimeSpan.FromSeconds(Config.implicitTimeout));
        }
    }
}
