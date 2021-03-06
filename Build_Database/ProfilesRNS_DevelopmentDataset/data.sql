/*
use test_data
select *  into [Profile.Cache.SNA.Coauthor] from [itwvdstp01,1650].[HCProfilesStgNew].[Profile.Cache].[SNA.Coauthor]
select *  into [Profile.Data.Publication.MyPub.General] from [itwvdstp01,1650].[HCProfilesStgNew].[Profile.Data].[Publication.MyPub.General]
select *  into [Profile.Import.Person] from [itwvdstp01,1650].[HCProfilesStgNew].[Profile.Import].Person
select *  into [Profile.Import.PersonAffiliation] from [itwvdstp01,1650].[HCProfilesStgNew].[Profile.Import].PersonAffiliation
select *  into [Profile.Data.Publication.Person.Add] from [itwvdstp01,1650].[HCProfilesStgNew].[Profile.Data].[Publication.Person.Add]
select *  into [Profile.Data.Publication.Person.Exclude] from [itwvdstp01,1650].[HCProfilesStgNew].[Profile.Data].[Publication.Person.Exclude]
select *  into [Profile.Import.Beta.Award] from [itwvdstp01,1650].[HCProfilesStgNew].[Profile.Import].[Beta.Award]
select *  into [Profile.Import.Beta.Narrative] from [itwvdstp01,1650].[HCProfilesStgNew].[Profile.Import].[Beta.Narrative]
select *  into [Profile.Data.Person] from [itwvdstp01,1650].[HCProfilesStgNew].[Profile.Data].Person
select * into [Profile.Data.Publication.Pubmed.Disambiguation.Affiliation] from [itwvdstp01,1650].[HCProfilesStgNew].[Profile.Data].[Publication.PubMed.DisambiguationAffiliation]

drop table [Profile.Cache.SNA.Coauthor]
drop table [Profile.Data.Publication.MyPub.General]
drop table [Profile.Import.Person]
drop table [Profile.Import.PersonAffiliation]
drop table [Profile.Data.Publication.Person.Add]
drop table [Profile.Data.Publication.Person.Exclude]
drop table [Profile.Import.Beta.Award]
drop table [Profile.Import.Beta.Narrative]
drop table [Profile.Data.Person]
*/


insert into [Profile.Import].Person
select * from Weekly_HCProfiles.[Profile.Import].Person where internalusername in (Select distinct internalusername from Weekly_HCProfiles.[Profile.Import].PersonAffiliation where InstitutionAbbreviation = 'HMS')
 
  insert into [Profile.Import].PersonAffiliation
  select t.* from Weekly_HCProfiles.[Profile.Import].[PersonAffiliation] t join [Profile.Import].Person p on p.internalusername = t.internalusername;

  update [Profile.Import].PersonAffiliation set InstitutionAbbreviation = 'HU'where institutionname = 'Harvard University'

  INSERT [Profile.Import].[User] ([internalusername], [firstname], [lastname], [displayname], [institution], [department], [emailaddr], [canbeproxy]) VALUES (N'ORNG', N'ORNG', N'ORNG', N'ORNG', NULL, NULL, N'ORNG', 0);
  INSERT [Profile.Import].[User] ([internalusername], [firstname], [lastname], [displayname], [institution], [department], [emailaddr], [canbeproxy]) VALUES (N'proxy1', N'HiddenDefault', N'Proxy', N'Hidden Default Proxy', NULL, NULL, N'proxy1@example.com', 0);
  INSERT [Profile.Import].[User] ([internalusername], [firstname], [lastname], [displayname], [institution], [department], [emailaddr], [canbeproxy]) VALUES (N'proxy2', N'VisibleDefault', N'Proxy', N'Visible Default Proxy', NULL, NULL, N'proxy2@example.com', 0);
  INSERT [Profile.Import].[User] ([internalusername], [firstname], [lastname], [displayname], [institution], [department], [emailaddr], [canbeproxy]) VALUES (N'proxy3', N'Hidden', N'Proxy', N'Hidden Proxy', NULL, NULL, N'proxy3example.com', 0);
  INSERT [Profile.Import].[User] ([internalusername], [firstname], [lastname], [displayname], [institution], [department], [emailaddr], [canbeproxy]) VALUES (N'proxy4', N'Visible', N'Proxy', N'Visible Proxy', NULL, NULL, N'proxy4@example.com', 1);
  
