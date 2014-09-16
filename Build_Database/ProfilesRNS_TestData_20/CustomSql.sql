 insert into [Profile.Data].[Publication.Person.Add] 
  select a.pubid, p.personid, a.pmid, a.mpid from test_data..[Profile.Data.Publication.Person.Add] a 
  join test_data..[profile.data.person] p1
    on a.personid = p1.PersonID
  join [Profile.Data].Person p
  on p.internalusername = p1.internalusername;

  insert into [Profile.Data].[Publication.MyPub.General]
  select g.MPID, a.personid, g.pmid, g.hmsPubCategory, g.NlmPubCategory, g.pubtitle, g.articleTitle, g.articletype, g.confeditors, g.confLoc, g.Edition,
  g.placeOfPub, g.VolNum, g.PartVolPub, g.IssuePub, g.paginationPub, g.AdditionalInfo, g.publisher, g.secondaryAuthors, g.confNm, g.ConfDTs, g.ReptNumber, g.contractNum, g.dissUnivNm,
  g.newspaperCol, g.NewspaperSect, g.PublicationDT, g.Abstract, g.Authors, g.URL, g.CreatedDT, g.CreatedBy, g.UpdatedDT, g.UpdatedBy
  from  test_data..[Profile.Data.Publication.MyPub.General] g join [Profile.Data].[Publication.Person.Add] a
  on g.mpid = a.MPID;

  delete from [Profile.Data].[Publication.Person.Add]  where mpid is not null 
  and mpid not in (select mpid from [Profile.Data].[Publication.MyPub.General])

    insert into [Profile.Data].[Publication.Person.Exclude] 
  select a.pubid, p.personid, a.pmid, a.mpid from test_data..[Profile.Data.Publication.Person.Exclude] a 
  join test_data..[profile.data.person] p1
    on a.personid = p1.PersonID
  join [Profile.Data].Person p
  on p.internalusername = p1.internalusername;

 insert into [Profile.Import].[Beta.Award]
  select a.awardID, p.personid, a.yr, a.yr2,a.awardnm, a.awardinginst from test_data..[Profile.Import.Beta.Award] a join test_data..[Profile.Data.Person] p1
  on a.personid = p1.personid 
  join [Profile.Data].Person p on p.InternalUsername = p1.internalusername;


   insert into [Profile.Import].[Beta.Narrative]
  select p.personid, a.narrativemain from test_data..[Profile.Import.Beta.Narrative] a join test_data..[Profile.Data.Person] p1
  on a.personid = p1.personid 
  join [Profile.Data].Person p on p.InternalUsername = p1.internalusername;

  update [User.Account].[User] set username = UserID, [Password] = UserID;
update [User.Account].[User] set username = 'ORNG', [Password] = 'ORNG' where DisplayName = 'ORNG';

EXEC [Framework.].[RunJobGroup] @JobGroup = 2;