using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SeleniumTests
{
    class Config
    {
        public static int commandTimeOut = 500;
        public static string URL = "http://profilestest/NWB_Profiles/search/";
        public static string sqlConnectionString = "Data Source=(local);Initial Catalog=ProfilesRNS_nwb;User ID=App_Profiles10;Password=Password1234";
        public static string username = "9";
        public static string password = "9";
        public static int personID = 9;
        public static string fileDir = "C://nwb/tmp/source/";
        public static int implicitTimeout = 10;
        public static int sleepTime = 2000;

        public enum SecurityOptions
        {
            OnlyME, Admins, Curators, Harvesters, Users, NoSearch, Public, Error
        }

    }
}
