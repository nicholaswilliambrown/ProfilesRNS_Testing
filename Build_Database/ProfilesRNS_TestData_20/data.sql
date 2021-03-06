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

SELECT top 2 PersonID1 as PersonID into #tmp0 FROM test_data.[Profile.Cache].[SNA.Coauthor] GROUP BY PersonID1 HAVING COUNT(*) > 4 ORDER BY NEWID();
select distinct top 10 PersonID2 as PersonID into #tmp1 from test_data.[Profile.Cache].[SNA.Coauthor] c join #tmp0 t on c.PersonID1 = t.PersonID;
select distinct top 20 PersonID2 as PersonID into #tmp2 from test_data.[Profile.Cache].[SNA.Coauthor] c join #tmp1 t on c.PersonID1 = t.PersonID;
select distinct top 30 PersonID2 as PersonID into #tmp3 from test_data.[Profile.Cache].[SNA.Coauthor] c join #tmp2 t on c.PersonID1 = t.PersonID;
select distinct top 40 PersonID2 as PersonID into #tmp4 from test_data.[Profile.Cache].[SNA.Coauthor] c join #tmp3 t on c.PersonID1 = t.PersonID;
select distinct top 50 PersonID2 as PersonID into #tmp5 from test_data.[Profile.Cache].[SNA.Coauthor] c join #tmp4 t on c.PersonID1 = t.PersonID;
select * into #tmp from #tmp0 union select * from #tmp1 union select * from #tmp2 union select * from #tmp3 union select * from #tmp4 union select * from #tmp5;
drop table #tmp0;
drop table #tmp1;
drop table #tmp2;
drop table #tmp3;
drop table #tmp4;
drop table #tmp5;
   
insert into [Profile.Import].Person
  select top 20 i.* from #tmp t 
  join test_data.[Profile.Data].[Person] p on t.PersonID = p.PersonID
  join test_data.[Profile.Import].[Person] i on i.internalusername = p.InternalUsername;

  insert into [Profile.Import].PersonAffiliation
  select t.* from test_data.[Profile.Import].[PersonAffiliation] t join [Profile.Import].Person p on p.internalusername = t.internalusername;

  INSERT [Profile.Import].[User] ([internalusername], [firstname], [lastname], [displayname], [institution], [department], [emailaddr], [canbeproxy]) VALUES (N'ORNG', N'ORNG', N'ORNG', N'ORNG', NULL, NULL, N'ORNG', 0);

  drop table #tmp;