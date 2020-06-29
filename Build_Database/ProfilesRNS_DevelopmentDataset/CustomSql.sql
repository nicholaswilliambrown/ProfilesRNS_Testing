/**
* Create and populate import tables
*
* You will need to add a database name before [Profile.Export] in each of the next 7 queries
**/
Select *, 0 as PersonID into [Profile.Import].Award from Weekly_HCProfiles.[Profile.Export].[Award] where InternalUsername in (select internalusername from [Profile.Import].Person)
Select *, 0 as PersonID into [Profile.Import].Overview from Weekly_HCProfiles.[Profile.Export].[Overview] where InternalUsername in (select internalusername from [Profile.Import].Person)
Select *, 0 as PersonID into [Profile.Import].[Person.Photo] from Weekly_HCProfiles.[Profile.Export].[Person.Photo] where InternalUsername in (select internalusername from [Profile.Import].Person)
Select *, 0 as PersonID into [Profile.Import].[Publication.MyPub.General] from Weekly_HCProfiles.[Profile.Export].[Publication.MyPub.General] where InternalUsername in (select internalusername from [Profile.Import].Person)
Select *, 0 as PersonID into [Profile.Import].[Publication.Person.Add] from Weekly_HCProfiles.[Profile.Export].[Publication.Person.Add] where InternalUsername in (select internalusername from [Profile.Import].Person)
Select *, 0 as PersonID into [Profile.Import].[Publication.Person.Exclude] from Weekly_HCProfiles.[Profile.Export].[Publication.Person.Exclude] where InternalUsername in (select internalusername from [Profile.Import].Person)
Select * into [Profile.Import].[RDF.Security.NodeProperty] from Weekly_HCProfiles.[Profile.Export].[RDF.Security.NodeProperty] where InternalUsername in (select internalusername from [Profile.Import].Person)
--select *, 0 as UserID into [Profile.Import].[DefaultProxy] from [Profile.Export].[DefaultProxy]
--select *, 0 as UserID, 0 as ProxyForUserID into [Profile.Import].[DesignatedProxy] from [Profile.Export].[DesignatedProxy]

/**
* Update Import tables with PersonID and UserID Values as appropriate
**/
Update a set PersonID = p.PersonID from [Profile.Import].Award a join [Profile.Data].Person p on a.InternalUsername = p.InternalUsername
Update a set PersonID = p.PersonID from [Profile.Import].Overview a join [Profile.Data].Person p on a.InternalUsername = p.InternalUsername
Update a set PersonID = p.PersonID from [Profile.Import].[Person.Photo] a join [Profile.Data].Person p on a.InternalUsername = p.InternalUsername
Update a set PersonID = p.PersonID from [Profile.Import].[Publication.MyPub.General] a join [Profile.Data].Person p on a.InternalUsername = p.InternalUsername
Update a set PersonID = p.PersonID from [Profile.Import].[Publication.Person.Add] a join [Profile.Data].Person p on a.InternalUsername = p.InternalUsername
Update a set PersonID = p.PersonID from [Profile.Import].[Publication.Person.Exclude] a join [Profile.Data].Person p on a.InternalUsername = p.InternalUsername
--Update a set UserID = u.userID from [Profile.Import].[DefaultProxy] a join [User.Account].[User] u on a.InternalUsername = u.InternalUserName
--Update a set UserID = u1.userID, ProxyForUserID = u2.UserID from [Profile.Import].[DesignatedProxy] a join [User.Account].[User] u1 on a.[User] = u1.InternalUserName join [User.Account].[User] u2 on a.ProxyForUser = u2.InternalUserName


/**
* Reconfigure the Beta Import values in the datamap to import Award data
* This needs to be done as the Unigue index doesn't allow us to simply add rows as it doesn't include DataMapGroup
**/
update [Ontology.].DataMap set [MapTable] = '[Profile.Import].[Award]' where MapTable = '[Profile.Import].[Beta.Award]'
update [Ontology.].DataMap set OrderBy = 'SortOrder' where Class = 'http://xmlns.com/foaf/0.1/Person' and NetworkProperty is null and Property = 'http://vivoweb.org/ontology/core#awardOrHonor' and sInternalType = 'Person'

/**
* Run ProcessDataMap for Award Data
**/
DECLARE @DMID int
DECLARE datamap_cursor CURSOR FOR  
SELECT DataMapID FROM [Ontology.].DataMap where MapTable = '[Profile.Import].[Award]' order by DataMapID
OPEN datamap_cursor   
FETCH NEXT FROM datamap_cursor INTO @DMID   

WHILE @@FETCH_STATUS = 0   
BEGIN   
       EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @DMID, @ShowCounts = 1

       FETCH NEXT FROM datamap_cursor INTO @DMID   
END   

CLOSE datamap_cursor   
DEALLOCATE datamap_cursor

/**
* Reconfigure the Beta Import values in the datamap to import Overview data
* Run ProcessDataMap for Overviews
**/
update [Ontology.].DataMap set MapTable = '[Profile.Import].Overview', oValue = 'cast(Overview as nvarchar(max))' where MapTable = '[Profile.Import].[Beta.Narrative]'
DECLARE @DMID_O int
select @DMID_O = DataMapID FROM [Ontology.].DataMap where MapTable = '[Profile.Import].Overview'
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @DMID_O, @ShowCounts = 1

/**
* Load Photo data and run ProcessDataMap for photo data
**/
insert into [Profile.Data].[Person.Photo] (PersonID, Photo, PhotoLink) select PersonID, Photo, PhotoLink from [Profile.Import].[Person.Photo]
DECLARE @DMID_P int
select @DMID_P = DataMapID FROM [Ontology.].DataMap where MapTable = '[Profile.Data].[vwPerson.Photo]'
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @DMID_P, @ShowCounts = 1

/**
* Load Custom Publications
**/
Insert into [Profile.Data].[Publication.MyPub.General]
SELECT [MPID],[PersonID],[PMID],[HmsPubCategory],[NlmPubCategory],[PubTitle],[ArticleTitle],[ArticleType],[ConfEditors],[ConfLoc],[EDITION],[PlaceOfPub]
,[VolNum],[PartVolPub],[IssuePub],[PaginationPub],[AdditionalInfo],[Publisher],[SecondaryAuthors],[ConfNm],[ConfDTs],[ReptNumber],[ContractNum],[DissUnivNm]
,[NewspaperCol],[NewspaperSect],[PublicationDT],[Abstract],[Authors],[URL],[CreatedDT],[CreatedBy],[UpdatedDT],[UpdatedBy]
  FROM [Profile.Import].[Publication.MyPub.General]

/**
* Load Added and excluded publications
**/
Insert into [Profile.Data].[Publication.Person.Add]
select PubID, PersonID, PMID, MPID from [Profile.Import].[Publication.Person.Add]

Insert into [Profile.Data].[Publication.Person.Exclude]
select PubID, PersonID, PMID, MPID from [Profile.Import].[Publication.Person.Exclude] 

/**
* Load user configured privicy settings
**/
insert into [RDF.Security].[NodeProperty]
select inmp.NodeID, n.NodeID as Property, case when np.ViewSecurityGroup < 0 then np.ViewSecurityGroup else inm.NodeID end as ViewSecurityGroup from [Profile.Import].[RDF.Security.NodeProperty] np
join [User.Account].[User] u on np.InternalUsername = u.InternalUserName
--join [Profile.Data].Person u on np.InternalUsername = u.InternalUserName
join [RDF.Stage].InternalNodeMap inm on inm.Class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User' and inm.InternalType = 'User'
and cast (u.UserID as nvarchar(55)) = inm.InternalID
join [RDF.Stage].InternalNodeMap inmp on inmp.Class = 'http://xmlns.com/foaf/0.1/Person' and inmp.InternalType = 'Person'
and cast (u.PersonID as nvarchar(55)) = inmp.InternalID
join [RDF.].Node n on np.PropertyURI = n.Value

/**
* Run ProcessDataMap for the entire datamap (This will only run datamap rows set to run automatically)
* and not the award and Overview rows we loaded earlier
**/
EXEC [RDF.Stage].[ProcessDataMap]

/**
* Update any custom security settings
* This has to be done after ProcessDataMap so that the triples exist
**/
update t
	set t.ViewSecurityGroup = n.ViewSecurityGroup
	from [RDF.Security].[NodeProperty] n, [RDF.].Triple t
	where n.NodeID = t.Subject and n.Property = t.Predicate

update [user.account].[user] set username = isnull(cast(personID as nvarchar(10)), 'u' + cast(userID as nvarchar(10)))
update [user.account].[user] set password = username
update [User.Account].[User] set username = 'ORNG', [Password] = 'ORNG' where DisplayName = 'ORNG';
update [User.Account].[User] set username = 'proxy1', [Password] = 'proxy1' where internalusername = 'proxy1';
update [User.Account].[User] set username = 'proxy2', [Password] = 'proxy2' where internalusername = 'proxy2';
update [User.Account].[User] set username = 'proxy3', [Password] = 'proxy3' where internalusername = 'proxy3';
update [User.Account].[User] set username = 'proxy4', [Password] = 'proxy4' where internalusername = 'proxy4';
update [User.Account].[User] set username = 'griffin', [Password] = 'griffin' where internalusername = '32213';
update [User.Account].[User] set username = 'nick', [Password] = 'nick' where internalusername = '125325';
update [User.Account].[User] set username = 'steve', [Password] = 'steve' where internalusername = '26052';
update [User.Account].[User] set username = 'james', [Password] = 'james' where internalusername = '55724';

insert into [User.Account].[DefaultProxy] (UserID, IsVisible) select UserID, 0 from [User.Account].[User] where InternalUserName = 'Proxy1'
insert into [User.Account].[DefaultProxy] (UserID, IsVisible) select UserID, 1 from [User.Account].[User] where InternalUserName = 'Proxy2'
insert into [Profile.Data].[Group.Admin] (UserID) select UserID from [User.Account].[User] where InternalUserName = 'Proxy1'
insert into [Profile.Data].[Group.Admin] (UserID) select UserID from [User.Account].[User] where InternalUserName = '125325'
insert into [Profile.Data].[Group.Admin] (UserID) select UserID from [User.Account].[User] where InternalUserName = '32213'


--select * from [Profile.Data].[Organization.Department]


DECLARE @DepatementName varchar(MAX)
DECLARE @departments CURSOR
SET @departments = CURSOR FOR
SELECT DepartmentName
FROM [Profile.Data].[Organization.Department]

OPEN @departments
	FETCH NEXT FROM @departments INTO @DepatementName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		exec [Profile.Data].[Group.AddUpdateGroup] @GroupName=@DepatementName, @ViewSecurityGroup=-1
		FETCH NEXT FROM @departments INTO @DepatementName
	END
	CLOSE @departments
DEALLOCATE @departments
GO

/*
select * from [User.Account].[User] where LastName like 'Brown'  
Update [User.Account].[User] set UserName = 'nick', Password='nick' where FirstName = 'Nicholas' and LastName = 'Brown'
Insert into [Profile.Data].[Group.Admin] (UserID) select UserID from [User.Account].[User] where FirstName = 'Nicholas' and LastName = 'Brown'
*/

GO

Select u.UserID, g.GroupID, /*pa.title*/ 'Member' title into #tmp from [User.Account].[User] u
join [Profile.Data].[Person.Affiliation] pa
on u.PersonID = pa.PersonID
join [Profile.Data].[Organization.Department] d
on pa.DepartmentID = d.DepartmentID
join [Profile.Data].[Group.General] g
on g.GroupName = d.DepartmentName

DECLARE @UserID int, @GroupID int, @title varchar(max)
DECLARE @memberships CURSOR
SET @memberships = CURSOR FOR
SELECT UserID, GroupID, Title 
FROM #tmp

OPEN @memberships
	FETCH NEXT FROM @memberships INTO @UserID, @GroupID, @title
	WHILE @@FETCH_STATUS = 0
	BEGIN
		exec [Profile.Data].[Group.Member.AddUpdateMember] @GroupID=@GroupID, @UserID=@UserID, @Title=@Title 
		FETCH NEXT FROM @memberships INTO @UserID, @GroupID, @title
	END
	CLOSE @memberships
DEALLOCATE @memberships
GO

  declare @groupID as int
  select @groupID = GroupID from [Profile.Data].[Group.General] where GroupName = 'Biomedical Informatics'
  exec [Profile.Data].[Group.AddPhoto] @GroupID=@GroupID, @Photo=0xFFD8FFE000104A46494600010101004800480000FFDB004300080606070605080707070909080A0C140D0C0B0B0C1912130F141D1A1F1E1D1A1C1C20242E2720222C231C1C2837292C30313434341F27393D38323C2E333432FFDB0043010909090C0B0C180D0D1832211C213232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232FFC00011080096009603012200021101031101FFC4001F0000010501010101010100000000000000000102030405060708090A0BFFC400B5100002010303020403050504040000017D01020300041105122131410613516107227114328191A1082342B1C11552D1F02433627282090A161718191A25262728292A3435363738393A434445464748494A535455565758595A636465666768696A737475767778797A838485868788898A92939495969798999AA2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE1E2E3E4E5E6E7E8E9EAF1F2F3F4F5F6F7F8F9FAFFC4001F0100030101010101010101010000000000000102030405060708090A0BFFC400B51100020102040403040705040400010277000102031104052131061241510761711322328108144291A1B1C109233352F0156272D10A162434E125F11718191A262728292A35363738393A434445464748494A535455565758595A636465666768696A737475767778797A82838485868788898A92939495969798999AA2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE2E3E4E5E6E7E8E9EAF2F3F4F5F6F7F8F9FAFFDA000C03010002110311003F00AC00DA381D3D28C0F41F9503EE8FA52D769E68981E83F2A303D07E54B45021303D07E54607A0FCA968A004C0F41F95181E83F2A5A2801303D07E54607A0FCA968A004C0F41F95181E83F2A5A2801303D07E54607A0FCA968A004C0F41F95181E83F2A5A2801303D07E54607A0FCA968A0064806CE83AFA51449F73F1A28290E1F747D296907DD1F4ADBD27C317DACD99B9B6920540E53123107231EDEF408C5A2BA9FF00840B55FF009ED69FF7D9FF000A827F04EB50A9658A19B1DA39067F238A2E82CCE768A927826B599A1B889E2917AA3AE0D3154B3AA8EAC4014084A2BA5FF84175AFFA75FF00BFBFFD6A3FE105D67FE9D7FEFEFF00F5A8BA1D99CD515BB71E0FD6EDD0BFD944A07FCF170C7F2EB586CAC8C5594AB29C104608340584A2AF695A4DD6B172D6F69E5F98A9BCEF6C0C671FD6B42F7C23AAD8594B7732C063897736C93271F4C5170B33068A28A041456CE99E18D4B56B3FB55B2C2222C54191F0491D7B545AB6837BA2AC4D77E5625242F96FBBA7FF00AE8B8ECCCBA2B5349F0FDF6B51CAF69E56D8982B798FB79355F53D32E349BC36B75B3CD0A1BE46C8C1A00A127DCFC68A24FB9F8D140D0E1F747D2BD23C05FF0022FC9FF5F0DFC96BCDC7DD1F4AF48F017FC8BF27FD7C37F25A4F608EE55D63C6775A6EAF73651D9C0EB13603331C9E01A65A7C4146902DED81453D5E17DD8FC0D73BE2AFF91A350FFAE83FF41158F459036EE7ADDFE9FA7F8934B52595D1D77433AF543EA3FA8AF2D92DA5B2D4FECD38C4B14C1587D0D767F0FAE99EDAF2CD8E563659107A6720FF002159BE348162F14412A8C79C91B1FA86C7F4142DEC37AAB9DD6AF7ADA7695757888AED0A6E0AC783CD717FF0B06F7FE7C2DBFEFB6AEC35EB69AF344BDB68137CD247B51738C9C8AF3BFF0084435DFF009F1FFC88BFE349586EFD0EB341F1826AD7AB673DB0826707632B65588E71EC6B3FC7FA7C4AB6DA82285959CC5211FC5C6413EFC1A5F0D784AF2C7528EFEFCC71F959291AB6E24E3193D80AADE39D5E0BB920D3EDE4120858BCACA7237630067F3A3AE82E9A90F807FE4373FF00D7B9FF00D0857A14B124F0C90C8329229461EC462BCF7C03FF0021B9FF00EBDCFF00E842BB317813C4AD62C7FD6DA2CA83DD5883FA1FD287B8E3B1E51756CF677935B49F7E17287F0350E09380324F007AD751E3AB1FB3EB4974A30972993FEF2F07F4C567F85AC7EDFE21B546198E23E6BFD17A7EB8AABE845B5B1E97A5590D3B49B5B41D628C06FF007BA9FD735CB7C43FF51A7FFBEFFC85749757B8D7AC2C41E6449257FA0181FA93F95737F10FFD469FFEFBFF002152B72DEC3FE1E7FC79EA1FF5D53F91AC6F1C7FC8CADFF5C53FAD6CFC3CFF008F3D43FEBAA7F2358DE38FF9195BFEB8A7F5A3A89FC273127DCFC68A24FB9F8D15424387DD1F4AF48F017FC8BF27FD7C37F25AF371F747D2BD23C05FF22FC9FF005F0DFC9693D823B9C878ABFE468D43FEBA0FFD04563D741E26D3EF65F125F49159DC3A338C32C4483C0EF552D3C37AC5EC8163B19514F57946C51F9D3426B53A1F87919F33509BF876A27E3C9AAFE38903788ECA307948D33F8B9AEB749D3ADBC3BA398DE51B50192798F009EE7E9D8579B6A5A81D575E7BC20859255080F650401FA525B94F4563D4F55BD3A769973782312185376C2719E7D6B8FF00F858727FD0313FEFF1FF000AE9FC4AACFE1CD41514B318B80A324F22BCA7EC775FF3EB71FF007E9BFC29209368F40D33C6163ABCEB63756A6169BE55DC43A31F43593E2FF0D5B585BAEA1609E545B82CB10E833D08F4FA566683A06A177AA5B486DA58A08E457796452A00073C67A9AECFC6B3247E1A9D588DD2BA220F539CFF002146CC375A9CCF807FE4373FFD7B9FFD0855EF14DF1D37C61A6DD8E91C4377BA9620FE9547C03FF21B9FFEBDCFFE84297E207FC86ADBFEBDC7FE8469F50FB2745E33B217BE1E7993E66B7613291DD7A1FD0E7F0ACFF87F63B6D6EAF98732B0890FB0E4FEA7F4AD4F0C5DAEABE198E397E664536F283DC0181FA114B71B3C31E10648D816862D88DFDE763D7F339FC29790FCCC5D3AFF00FB47E234B2A9CC691BC51FD1463F9E4D3BE21FFA8D3FFDF7FE42B1FC11FF0023345FF5C9FF00956C7C43FF0051A7FF00BEFF00C853EA2E83FE1E7FC79EA1FF005D53F91AC6F1C7FC8CADFF005C53FAD6CFC3CFF8F3D43FEBAA7F2358DE38FF009195BFEB8A7F5A5D41FC273127DCFC68A24FB9F8D15424387DD1F415D8F85BC4BA768FA535B5D99BCC33338D91E46081EFED5C70FBA3E94B91EB435712763D2FFE13BD1BFBD75FF7EBFF00AF55EE3C7FA7A29F22DAE666EDBB083FAD79DE47A8A323D452E543E666CEB3E24BFD6BE494AC56E0E4431F4FC4F7AC98D82CB1B1E8AC09FCE9991EA28C8F514C47A61F1D68B9C8375FF7E7FF00AF47FC277A3FF7AEBFEFD7FF005EBCCF23D45191EA2972A1F333D16E3C7DA7229305BDCCCFDB70083F3AE3759D6EEF5BB912DC10A89C47127DD4FF0013EF59991EA28C8F514EC26DB377C2BAB5AE8FA94B7177E66C688A0D8BB8E720FF004A5F156AD6BACEA30CF69E66C48761DEBB4E724FF5AC1C8F514647A8A2C17D2C747E14D7E0D167B85BBF33ECF3283F22E4861EDF426A6F15F892DB5982DEDECBCDF2918BC9BD76E4F41FD6B96C8F514647A8A2C17D2C6C786B52B7D2B5A4BBBADFE508D94EC5C9C91C56878B75EB1D6A3B45B332E62662DE626DEA07F8572F91EA28C8F5145B50BE963AAF096BF63A2DBDDA5E19774AEACBE5A6EE00ACEF136A76FAB6B2D756BBFCA31AAFCEB839158D91EA29739A2DADC2FA58649F73F1A2893EE7E345034387DD1F4A9D2EA78D022485547402A01F747D2993CA20B7926604AA0C9028049B7645CFB6DCFF00CF66FD28FB6DCFFCF66FD2AAA43AAC88AE9A0EA4CAEA5D584270547523DAABDB5CDD5EB4AB6BA55ECE61FF0058238F76CFAE3A547B58773ABEA388DF97F15FE6697DB6E7FE7B37E947DB6E7FE7B37E959F7335E59CF14175A4DF432CBFEAD248F697FA0EF524C9A9DB4324D3E87A8C7147CBBBC2405EFC9A3DAC3B87D4711FCBBF9AFF0032E7DB6E7FE7B37E947DB6E7FE7B37E95521904D0A4A0101D43006ADCF66D0595ADC991596E4315500E46D3839AB391A69D987DB6E7FE7B37E947DB6E7FE7B37E945E5A359491A348AFE6449282A08C0619029D75A7CF676D693CB8D97485D31DB07A1F7E87F11400DFB6DCFFCF66FD28FB6DCFF00CF66FD2A6834D12DAC13BDD47109E530A06563F30C7523A0E473443A64D2DE5CDA332C73DBA3B321E7714EA063BF14010FDB6E7FE7B37E947DB6E7FE7B37E94D583364D725C00241185C72C71938FA7F51524BA7CF169905FB63C999D9147718F5FAF38FA50037EDB73FF3D9BF4A3EDB73FF003D9BF4A921B0592C7ED725D2431F9DE4FCC8C7E6C673C76C53E3D2676D59F4D91D23990B649E57819EDEA28020FB6DCFFCF66FD2A292592660D2396206066AC1B1DD66F776F324F14640940055933D0907B7B8AA9400C93EE7E345127DCFC68A06870FBA3E9505F2B3D8CCA818BB2E1420F989CF18F7A9C7DD1F4A86F4BAD8CCD1B15755DCA54E08239C8A52D99747F891F5475A7C4FA1594F6B0DDA6A36D7CDB642B3DBB6E76036AE148CF3DF19E6B0ECB54B0D2EE2FE1D6A4D52D5A7BB1756E934255A4C640E08E84F07E82B9AD393FB7B5C863D4B519C5C3AECB6B99642FB251CA6E2790B9CF23A75ADFB1F086B1AAEB2E9E24835264B4FBF74D2F9810609014F258138236FBF4CD702773E9AB60E3875384E4BA7F48D4F11F886CADB57F0FCAFFDA16D15AC8CEE2781A22E09249C1033CB638CF19A9354D5B47D360B9679B55B433A3FD9E39AD4C48C4A907665474C8FD2B8DF11DA5C49E24BEB092F67BD8AC6668966BC98B08D738E58F039E3F0AA7AC4D2CF75F679F5493538E0E1267919D3381BB66EED9E33DF14B9AC6B0CB7DAF228C96D7EBEBAE9E66D587FC83ADBFEB9AFF2ADFB8BEF2B45D32289A0775597CC564572B96C8EA0E38AC1B25DB636EB8C6235E3F0AD1BBB096CE0B59E4C18EE62F32361F9107DC7F5AF416C8F93A9F1CBD4BDA8182FB57B30D710889ADE1595D58055C2FCC38E01F6A927BEB6D4B4CBD8CAF91224A2E21124A0E7F8591781FC38E3DAB36FAC25D3A48A39F1BE48965C0FE10DD01F7A96EF4D5B3778E4BD84CAA81C2056E7201001C633834C82FE9F7F6B69A6D80B848A50B75233AF05E205540703D4119E7AE2A88B87D375D1722E12E9A39BCC32A9C8941EBF982722A38EC03582DE49731C51B4A621956277019EC3A629B3D84B6F7715BCA53F7BB4C7229DCACADD181F4A00B3A9ADB1BF4B2B29D4DAA31D929385CB1C927E8303FE03574DE595D45A8580FDD47E5A98249251B7745C2E0638DC33DFBD65FF0066CE754934F8CABCB1B32B3670A36FDE249E8060F351CB6F1244CF1DE4529520150ACA4FB8C8E45006969D7B6B69A427DA2286E00BD0EF039F9B66CC6E03EB4FB678E2F1499A5BF8E78DC48FF69660376E438CFA1E40C5662D84EFA649A8003C88E5111F5C91D7E9D07E34D8AD1A5B1B8BA1228580A86520E4EE3818FCA802E5A98F4ED3AF7CD9A279EE61F212289C3E012096623818C71597451400C93EE7E345127DCFC68A06870FBA3E94328652ADD08C1A07DD1F4A5A0472E96B00BD6B6BE9DA089721A458BCC3EDF2F19CD7A67877C49766DED2C344D2F5DD434D82311DC5D2B08DFB70AA3E518C75DD923BD711AB589993ED112E6441F328FE25FF001AD58BC6F169BE13BCD17478F538FED2BB55AEAE51D6DC1EA130A0E0827D31D4570CA3ECE563EADD5798D184A29CA4B46BA27DFBEBBF634EE7498EC75ED7A0D5AD1DF4CBE8DF50B5BF2BF2AFCA48049E324315F504F1D6BCF6DA16B89A3880C173D3D077FCABBAD775EB4F12F828B4D64F68DA688A0B3B879158DD10402846320800B71902B034AB136E9E7CA312B8E01FE11FE34461CF24BA0E38C583C34EA4B49BF752F45BFF0099A3800600E00C0AE892EAD1A292CEF24531DBA45716E54E433AA00C9FF02FE95CF55D5D3B10C2F35CC3019D0BC4AFBB2CBC8C9206064838CD771F264BACCFF6A8F4F94CAB24A6D40976B02436E6E0FA70455BD658DC4B218E5B1680431FCC193792A83201FBC4E462B2ADACE4B98E59B72450C407992C87819E838E493E82924B745788477114AB21C065C8DBCE3904645005F8D44FE1C8E04961128BC6728F2AA90BB00CF27A668BB9E1326956914CB20B450AF283852C5F71C13D867AD561A5CADACFF65F991F9DE698B773B770FC3351DBD9BDC2CD20744861FF00592BE768C9C01EA49EC2803505DDB2F88754124CAB05D89A2132FCC1771CAB71DBA67EB5972D93C3133BCB6E70405549958BFB8C76FAE28B8B368208EE164496DE4255644CE370EA083C83537F6548264B7927823BA9002B03139E7A0271804F1C13DE8034EDAE2C526FECA77C42F6C6DDA7F34795B8FCFBFA7F7B1DFB551B150DA3EA56E658565778B6ABC81776D2738CD5582C259FED60911B5AC664915C1CE01C11F5C9AAB405C92784C127965E37380498DB70E7B64547451408649F73F1A2893EE7E3450521C3EE8FA52D20FBA3E94B41215957FA57984CD6C0073CB27407DC7BD6AD15338292B33A30B8AAB85A9ED293B3FEB732F4FD2561713CE15A5ECA3A2FF89AD4A28A231515642C4626A626A3A955DD856F584C1ED22B7D4BECB369C118AB9702583AF0BFC59CF6C1073583455189A768F1DC68971606548EE3CF59E3F30ED12614A95CF4079C8CFBD5536CD6F341BDE2DCCE32AB206DB823AE38155A8A00E953515FF84CCB13682DFED4C7CED89F779E777F5ACDB5749749BBD3CBA47334E93465D800F80415CF4CF39159945160B9A9248967A28B367492E24B913B22B0608AA3001238C9CFE42A6BE8A3BFD69EFE3B9856D67904ACED200D1F42415EB91EC39E2B168A02E6F43771DF6A3AECEAC910BA824F2848E1724B2E073DF02B1E7B76B72A1DE366619C46E1B1CF7238CD434500145145021927DCFC68A24FB9F8D14148048BB475E9E94798BEFF0095145020F317DFF2A3CC5F7FCA8A2800F317DFF2A3CC5F7FCA8A2800F317DFF2A3CC5F7FCA8A2800F317DFF2A3CC5F7FCA8A2800F317DFF2A3CC5F7FCA8A2800F317DFF2A3CC5F7FCA8A2800F317DFF2A3CC5F7FCA8A2800F317DFF2A3CC5F7FCA8A2801B248BB3BF5F4A28A2819FFD9

  
  declare @GroupNodeID bigint
select @GroupNodeID = GroupNodeID From [Profile.Data].[vwGroup.General] where GroupName = 'Biomedical Informatics'

declare @p5 nvarchar(1)
set @p5=N'0'
declare @object bigint
exec [RDF.].GetStoreNode @value=N'Over 100 years ago, Abraham Flexner reviewed the state of U.S. medical education and its impact on the practice of medicine. What he reported about the lack of modern science in medicine caused half of the medical schools in this country to close. Today we are at another Flexnerian moment. Medicine and biomedical science are data- and knowledge-processing enterprises that are largely conducted without any of the modern tools of quantitative analysis or automation.

On July 1, 2015, we inaugurated the Department of Biomedical Informatics at Harvard Medical School. This new department, built on our ten-year history as the former Center for Biomedical Informatics, will bring quantitative methods and engineering to biomedicine at HMS. It is our mission to ensure that the next 100 years result in the breakthrough treatments and scientific insights we presaged in a New England Journal of Medicine piece entitled "A Glimpse of the Next 100 Years in Medicine."',@language=default,@DataType=default,@SessionID=N'8bad285c-2805-47da-a751-ae70304948f4',@Error=@p5 output,@NodeID=@object output

declare @predicate bigint
select @predicate = NodeID from [RDF.].Node where value = 'http://profiles.catalyst.harvard.edu/ontology/prns#welcome'

  declare @p6 bit
set @p6=0
exec [RDF.].GetStoreTriple @subjectid=@GroupNodeID,@predicateid=@predicate,@objectid=@object,@sessionID=N'8bad285c-2805-47da-a751-ae70304948f4',@error=@p6 output

declare @p52 nvarchar(1)
set @p52=N'0'
declare @object2 bigint
exec [RDF.].GetStoreNode @value=N'Department of Biomedical Informatics
Harvard Medical School
10 Shattuck Street
4th Floor
Boston, MA 02115
Phone: (617) 432-2144
Fax: (617) 432-0693
e-mail: dbmi@hms.harvard.edu',@language=default,@DataType=default,@SessionID=N'8bad285c-2805-47da-a751-ae70304948f4',@Error=@p52 output,@NodeID=@object2 output

declare @predicate2 bigint
select @predicate2 = NodeID from [RDF.].Node where value = 'http://vivoweb.org/ontology/core#contactInformation'

  declare @p62 bit
set @p62=0
exec [RDF.].GetStoreTriple @subjectid=@GroupNodeID,@predicateid=@predicate2,@objectid=@object2,@sessionID=N'8bad285c-2805-47da-a751-ae70304948f4',@error=@p62 output


insert into [Profile.Data].[Publication.Group.Option] (GroupID, IncludeMemberPublications)
  select GroupID, 1 from [Profile.Data].[Group.General] where GroupName = 'Biomedical Informatics'
  
  
  insert into [ORNG.].[AppData] (NodeID, AppID, Keyname, Value, CreatedDT, UpdatedDT)
select GroupNodeID, 112, 'twitter_username', 'HarvardDBMI', GETDATE(), GETDATE() From [Profile.Data].[vwGroup.General] where GroupName = 'Biomedical Informatics'

insert into [ORNG.].[AppData] (NodeID, AppID, Keyname, Value, CreatedDT, UpdatedDT)
select GroupNodeID, 103, 'links_count', '1', GETDATE(), GETDATE() From [Profile.Data].[vwGroup.General] where GroupName = 'Biomedical Informatics'

insert into [ORNG.].[AppData] (NodeID, AppID, Keyname, Value, CreatedDT, UpdatedDT)
select GroupNodeID, 103, 'link_0', '{"name":"Department of Biomedical Informatics","url":"http://dbmi.hms.harvard.edu/"}', GETDATE(), GETDATE() From [Profile.Data].[vwGroup.General] where GroupName = 'Biomedical Informatics'

--@SubjectID BIGINT=NULL, @SubjectURI nvarchar(255)=NULL, @PluginName varchar(55), @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT, @NodeID BIGINT=NULL OUTPUT


select @groupID = GroupID from [Profile.Data].[Group.General] where GroupName = 'Biomedical Informatics'

declare @SubjectID BIGINT
select @SubjectID=NodeID from [RDF.Stage].InternalNodeMap where InternalID = cast(@groupID as nvarchar(100)) and class = 'http://xmlns.com/foaf/0.1/Group'

--exec [Profile.Module].[GenericRDF.AddEditPluginData] @Name='Twitter',@NodeID=@SubjectID, @Data='HarvardDBMI', @SearchableData='HarvardDBMI'

exec [Edit.Module].[CustomEditWebsite.AddEditWebsite] @NodeID=@SubjectID, @URL='http://dbmi.hms.harvard.edu/', @WebPageTitle='Department of Biomedical Informatics', @Predicate='http://vivoweb.org/ontology/core#webpage'