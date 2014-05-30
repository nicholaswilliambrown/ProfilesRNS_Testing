using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections.Specialized;
using System.Net;
using System.IO;
using System.Xml.Linq;
using System.Xml;
using System.Data.SqlClient;
using System.Data;

namespace API_test
{
    class Program
    {
        public static string uri = "http://profilestest/ProfilesSearchAPI/ProfilesSearchAPI.svc/Search";

        static void Main(string[] args)
        {
            //new prnsAPI();
            makeLinksPage();
            //Console.In.ReadLine();
        }


        static void makeLinksPage()
        {
            string sqlConnectionString = "Data Source=(local);Initial Catalog=ProfilesRNS_test3_debug;User ID=App_Profiles10;Password=Password1234";
            int commandTimeOut = 500;
            SqlConnection dbconnection = new SqlConnection(sqlConnectionString);
            SqlCommand dbcommand = new SqlCommand(
                //--People
                "select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person'" +
                //--People with concepts
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/Network/ResearchAreas' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/network/researchareas/categories' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/network/researchareas/timeline' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/network/researchareas/details' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/network/researchareas/cloud' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/Network/SimilarTo' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/network/similarto/map' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/network/similarto/details' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/network/similarto/list' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                //--People with CoAuthors
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/Network/CoAuthors' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid1 from [Profile.Cache].[SNA.Coauthor])" +
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/network/coauthors/map' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid1 from [Profile.Cache].[SNA.Coauthor])" +
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/network/coauthors/radial' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid1 from [Profile.Cache].[SNA.Coauthor])" +
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/network/coauthors/cluster' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid1 from [Profile.Cache].[SNA.Coauthor])" +
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/network/coauthors/timeline' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid1 from [Profile.Cache].[SNA.Coauthor])" +
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/network/coauthors/details' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid1 from [Profile.Cache].[SNA.Coauthor])" +
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) + '/network/coauthors/list' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid1 from [Profile.Cache].[SNA.Coauthor])" +
                //--Organizations (these should render, but are not very interesting)
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Organization'" +
                //--Concepts
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) as url from [RDF.Stage].[InternalNodeMap] where class = 'http://www.w3.org/2004/02/skos/core#Concept'" +
                //--Publications
                "union select 'http://localhost:55956/display/' + convert (nvarchar(50), NodeID) as url from [RDF.Stage].[InternalNodeMap] where class = 'http://vivoweb.org/ontology/core#InformationResource'" +
                //--Search
                "union select 'http://localhost:55956/search/default.aspx?searchtype=people&lname=&searchfor=asthma&exactphrase=false&institution=&classuri=http://xmlns.com/foaf/0.1/Person&perpage=15&offset=0'  as url" +
                "union select 'http://localhost:55956/search/default.aspx?searchtype=everything&searchfor=asthma&exactphrase=false' as url"
                );

            SqlDataReader dbreader;
            dbconnection.Open();
            dbcommand.CommandType = CommandType.Text;
            dbcommand.CommandTimeout = commandTimeOut;
            //dbcommand.Parameters.Add(new SqlParameter("@userid", sm.Session().UserID));
            dbcommand.Connection = dbconnection;
            dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection);
            using (System.IO.StreamWriter file = new System.IO.StreamWriter(@"C:\inetpub\wwwroot\index.html"))
            {
                file.WriteLine("<!DOCTYPE html PUBLIC \"-//IETF//DTD HTML 2.0//EN\"><HTML><HEAD><TITLE>List of pages to test</TITLE></HEAD><BODY>");
                while (dbreader.Read())
                {
                    if (dbreader["url"] != null)
                    {
                        file.WriteLine("<a href=\"" + dbreader["url"] + "\">" + dbreader["url"] + "</a>");
                    }
                }
                file.WriteLine("</BODY></HTML>");
            }
        }

    }
}
