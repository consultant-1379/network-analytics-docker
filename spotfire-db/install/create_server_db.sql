/*
 * Copyright (c) 2008-2018 Spotfire AB,
 * Första Långgatan 26, SE-413 28 Göteborg, Sweden.
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Spotfire AB ("Confidential Information"). You shall not
 * disclose such Confidential Information and may not use it in any way,
 * absent an express written license agreement between you and Spotfire AB
 * or TIBCO Software Inc. that authorizes such use.
 */

:on ERROR EXIT

go

set QUOTED_IDENTIFIER on

go

use master

go

-- If running the scripts on a SQL Server instance with a case sensitive server collation, 
-- explicitly set a (case insensitive) collation to be used by the database. 
-- See the example below.
--create database $(SERVERDB_NAME) collate Latin1_General_CI_AS;
create database $(SERVERDB_NAME)

go

use $(SERVERDB_NAME)

go

create table "SN_VERSION" (
  "SPOTFIRE_VERSION" nvarchar(20) not null,
  "SCHEMA_VERSION" nvarchar(20) not null,
  "ENCRYPTION_CANARY" varchar(400) null)

go

create table "LICENSE_NAMES" (
  "LICENSE_NAME" nvarchar(256) not null)

go

alter table "LICENSE_NAMES"
  add constraint "LICENSE_NAMES_PK" primary key ("LICENSE_NAME")


go

create table "PREFERENCE_OBJECTS" (
  "CLASS_NAME" nvarchar(200) not null,
  "OBJECT_NAME" nvarchar(250) not null,
  "LAST_MODIFIED" datetime null,
  "USER_ID" char(36) null,
  "GROUP_ID" char(36) null,
  "IS_DEFAULT" smallint null,
  "OBJECT_VALUE" varchar(8000) null,
  "OBJECT_BLOB_VALUE" image null)

go

alter table "PREFERENCE_OBJECTS"
  add constraint "PREFERENCE_OBJECTS_PK" primary key ("CLASS_NAME", "OBJECT_NAME")

go

create table "LICENSE_ORIGIN" (
  "PACKAGE_ID" char(36) null,
  "ASSEMBLY_QUALIFIED_NAME" nvarchar(400) not null,
  "LICENSE_FUNCTION_ID" char(36) not null)

go

create table "EXCLUDED_FUNCTIONS" (
  "CUSTOMIZED_LICENSE_ID" char(36) not null,
  "LICENSE_FUNCTION_ID" char(36) not null)

go

alter table "EXCLUDED_FUNCTIONS"
  add constraint "EXCLUDED_FUNCTIONS_PK" primary key ("CUSTOMIZED_LICENSE_ID", "LICENSE_FUNCTION_ID")

go

create table "CUSTOMIZED_LICENSES" (
  "CUSTOMIZED_LICENSE_ID" char(36) not null,
  "GROUP_ID" char(36) not null,
  "LICENSE_NAME" nvarchar(256) null)

go

alter table "CUSTOMIZED_LICENSES"
  add constraint "CUSTOMIZED_LICENSES_PK" primary key ("CUSTOMIZED_LICENSE_ID")


go

create table "LICENSE_FUNCTIONS" (
  "LICENSE_FUNCTION_ID" char(36) not null,
  "LICENSE_NAME" nvarchar(256) not null,
  "LICENSE_FUNCTION_NAME" nvarchar(50) not null)

go

alter table "LICENSE_FUNCTIONS"
  add constraint "LICENSE_FUNCTIONS_PK" primary key ("LICENSE_FUNCTION_ID")

go

create table "PREFERENCE_VALUES" (
  "PREFERENCE_VALUE" varchar(8000) null,
  "LAST_MODIFIED" datetime not null,
  "USER_ID" char(36) null,
  "GROUP_ID" char(36) null,
  "PREFERENCE_ID" char(36) not null,
  "PREFERENCE_BLOB_VALUE" image null)

go

create table "DEP_AREA_ALLOWED_GRP" (
  "AREA_ID" char(36) not null,
  "GROUP_ID" char(36) not null)

go

alter table "DEP_AREA_ALLOWED_GRP"
  add constraint "DEP_AREA_ALLOWED_GRP_PK" primary key ("GROUP_ID")

go

create index "DEP_AREA_ALWD_GRP_AREA_ID_IDX" 
	on "DEP_AREA_ALLOWED_GRP" ("AREA_ID")  
go

create table "GROUP_MEMBERS" (
  "GROUP_ID" char(36) not null,
  "MEMBER_USER_ID" char(36) null,
  "MEMBER_GROUP_ID" char(36) null)

go

create index "GROUP_MEMBER_REVERSE_USER_IX"
  on "GROUP_MEMBERS" ("MEMBER_USER_ID", "GROUP_ID")

go

create index "GROUP_MEMBER_REVERSE_GRP_IX"
  on "GROUP_MEMBERS" ("MEMBER_GROUP_ID", "GROUP_ID")

go

create table "USERS" (
  "USER_ID" char(36) not null,
  "USER_NAME" nvarchar(200) not null,
  "DOMAIN_NAME" nvarchar(200) not null,
  "EXTERNAL_ID" nvarchar(450) null,
  "PRIMARY_GROUP_ID" char(36) null,
  "LAST_MODIFIED_MEMBERSHIP" datetime null,
  "PASSWORD" varchar(150) null,
  "DISPLAY_NAME" nvarchar(450) not null,
  "EMAIL" nvarchar(450) null,
  "ENABLED" smallint not null,
  "LOCKED_UNTIL" datetime null,
  "LAST_LOGIN" datetime null)

go

create view GROUP_MEMBERS_VIEW as 
  select GROUP_ID, MEMBER_USER_ID, MEMBER_GROUP_ID from GROUP_MEMBERS
  union all
  select '19e7e430-9997-11da-fbc4-0010ac110215' as GROUP_ID, u.USER_ID as MEMBER_USER_ID, null as MEMBER_GROUP_ID 
  from USERS u where u.DOMAIN_NAME !=  N'ANONYMOUS'

go

alter table "USERS"
  add constraint "USERS_PK" primary key ("USER_ID")


go

create table "GROUPS" (
  "GROUP_ID" char(36) not null,
  "GROUP_NAME" nvarchar(200) not null,
  "DOMAIN_NAME" nvarchar(200) not null,
  "EXTERNAL_ID" nvarchar(450) null,
  "PRIMARY_GROUP_ID" char(36) null,
  "DISPLAY_NAME" nvarchar(450) not null,
  "EMAIL" nvarchar(450) null,
  "CONNECTED" smallint not null)

go

alter table "GROUPS"
  add constraint "GROUPS_PK" primary key ("GROUP_ID")
  
go

create table "DEP_AREAS_DEF" (
	"AREA_ID" char(36) not null,
	"DEP_AREA_NAME" nvarchar(50) not null,
	"IS_DEFAULT_AREA" bit not null,
	constraint "DEP_AREAS_DEF_PK" primary key ("AREA_ID"), 
	constraint "DEP_AREAS_DEF_UC1" unique ("DEP_AREA_NAME") )

go

create table "DEP_AREAS" (
  "AREA_ID" char(36) not null,
  "DISTRIBUTION_ID" char(36) not null,
  "DEPLOYMENT_TIME" datetime not null,
  "STATE" smallint null,
  "URL" nvarchar(50) null)

go

alter table "DEP_AREAS"
  add constraint "DEP_AREAS_PK" primary key ("AREA_ID")

go

create table "DEP_DISTRIBUTION_CONTENTS" (
  "PACKAGE_ID" char(36) not null,
  "DISTRIBUTION_ID" char(36) not null)

go

alter table "DEP_DISTRIBUTION_CONTENTS"
  add constraint "DEP_DISTRIBUTION_CONTENTS_PK" primary key ("PACKAGE_ID", "DISTRIBUTION_ID")

go

create table "DEP_DISTRIBUTIONS" (
  "DISTRIBUTION_ID" char(36) not null,
  "NAME" nvarchar(200) not null,
  "MODIFIED_DATE" datetime not null,
  "VERSION" nvarchar(50) null,
  "ADDINS_XML" image null,
  "MANIFEST_XML" image null,
  "DESCRIPTION" nvarchar(400) null,
  "METADATA_XML" image null)

go

alter table "DEP_DISTRIBUTIONS"
  add constraint "DEP_DISTRIBUTIONS_PK" primary key ("DISTRIBUTION_ID")

go

create table "DEP_PACKAGES" (
  "PACKAGE_ID" char(36) not null,
  "SERIE_ID" char(36) not null,
  "NAME" nvarchar(200) not null,
  "ZIP" image not null,
  "MODIFIED_DATE" datetime not null,
  "VERSION" nvarchar(32) not null,
  "DESCRIPTION" nvarchar(400) null)

go

create table "PREFERENCE_KEYS" (
  "CATEGORY_NAME" varchar(250) not null,
  "PREFERENCE_NAME" nvarchar(200) not null,
  "CLASS_TYPE" varchar(250) not null,
  "PREFERENCE_ID" char(36) not null)

go

alter table "PREFERENCE_KEYS"
  add constraint "PREFERENCE_KEYS_PK" primary key ("PREFERENCE_ID")

go

alter table "LICENSE_FUNCTIONS" add constraint "LICENSE_FUNCTIONS_UC1" unique (
  "LICENSE_FUNCTION_NAME",
  "LICENSE_NAME")

go

alter table "PREFERENCE_VALUES" add constraint "PREFERENCE_VALUES_UC1" unique (
  "GROUP_ID",
  "USER_ID",
  "PREFERENCE_ID")

go

create unique index "GROUP_MEMBER_IX" on "GROUP_MEMBERS" (
  "GROUP_ID",
  "MEMBER_GROUP_ID",
  "MEMBER_USER_ID")

go

create index "GROUP_MEMBER_GROUP_MEMBER_USER_IX" on "GROUP_MEMBERS" (
  "GROUP_ID",
  "MEMBER_USER_ID")

go

alter table "USERS" add constraint "USERS_UC1" unique ("USER_NAME", "DOMAIN_NAME")

go

create unique index "UNIQUE_GROUP_NAME" on "GROUPS" ("GROUP_NAME", "DOMAIN_NAME")

go

create index "GROUPS_PRIMARY_GROUP_ID_IDX" on "GROUPS" ("PRIMARY_GROUP_ID")

go

create index "USERS_PRIMARY_GROUP_ID_IDX" on "USERS" ("PRIMARY_GROUP_ID")

go

create unique index "DEP_PACKAGES_PK" on "DEP_PACKAGES" (
  "PACKAGE_ID")

go

alter table "DEP_PACKAGES" add constraint "DEP_PACKAGES_PK_UC1" unique (
  "PACKAGE_ID")

go

alter table "PREFERENCE_KEYS" add constraint "PREFERENCE_KEYS_UC1" unique (
  "CATEGORY_NAME",
  "PREFERENCE_NAME",
  "CLASS_TYPE")

go

alter table "PREFERENCE_OBJECTS"
  add constraint "GROUPS_PREFERENCE_OBJECTS_FK1" foreign key (
    "GROUP_ID")
   references "GROUPS" (
    "GROUP_ID") on update no action on delete cascade

go

alter table "PREFERENCE_OBJECTS"
  add constraint "USERS_PREFERENCE_OBJECTS_FK1" foreign key (
    "USER_ID")
   references "USERS" (
    "USER_ID") on update no action on delete cascade

go

alter table "LICENSE_ORIGIN"
  add constraint "DEP_PKGS_LIC_ORIGIN_FK1" foreign key (
    "PACKAGE_ID")
   references "DEP_PACKAGES" (
    "PACKAGE_ID") on update no action on delete set null

go

alter table "LICENSE_ORIGIN"
  add constraint "LIC_FUNS_LIC_ORIGIN_FK1" foreign key (
    "LICENSE_FUNCTION_ID")
   references "LICENSE_FUNCTIONS" (
    "LICENSE_FUNCTION_ID") on update no action on delete cascade

go

/* Trigger instead of foreign key constraint due to MSSQL limitations ("recursive" triggers) */
create trigger EXCLUDED_FUNCTIONS_INSERT_TR on "EXCLUDED_FUNCTIONS" after insert, update
	as
	if (select count(*) from "EXCLUDED_FUNCTIONS" 
 	    where CUSTOMIZED_LICENSE_ID not in (
	      select "CUSTOMIZED_LICENSE_ID" from "CUSTOMIZED_LICENSES")) > 0
	BEGIN
	   RAISERROR ('Constraint: invalid CUSTOMIZED_LICENSE_ID', 16, 1)
	   ROLLBACK TRANSACTION
	END

go

/* Trigger instead of foreign key constraint due to MSSQL limitations ("recursive" triggers) */
create trigger CUSTOMIZED_LIC_EXCLUDED_FN_TR on "CUSTOMIZED_LICENSES" after delete 
	as
	Delete from "EXCLUDED_FUNCTIONS"
	where "CUSTOMIZED_LICENSE_ID" in 
	    (SELECT d."CUSTOMIZED_LICENSE_ID"
	        from DELETED d 
	    )

go

alter table "EXCLUDED_FUNCTIONS"
  add constraint "LIC_FUNS_EXCL_FUNS_FK1" foreign key (
    "LICENSE_FUNCTION_ID")
   references "LICENSE_FUNCTIONS" (
    "LICENSE_FUNCTION_ID") on update no action on delete cascade

go

alter table "CUSTOMIZED_LICENSES"
  add constraint "GROUPS_CUSTOMIZED_LICENSES_FK1" foreign key (
    "GROUP_ID")
   references "GROUPS" (
    "GROUP_ID") on update no action on delete cascade

go

alter table "CUSTOMIZED_LICENSES"
  add constraint "LICENSE_NAMES_CUST_LIC_FK1" foreign key (
    "LICENSE_NAME")
   references "LICENSE_NAMES" (
    "LICENSE_NAME") on update no action on delete cascade

go

alter table "LICENSE_FUNCTIONS"
  add constraint "LICENSE_NAMES_LIC_FUNS_FK1" foreign key (
    "LICENSE_NAME")
   references "LICENSE_NAMES" (
    "LICENSE_NAME") on update no action on delete cascade

go

alter table "PREFERENCE_VALUES"
  add constraint "GROUPS_PREFERENCE_VALUES_FK1" foreign key (
    "GROUP_ID")
   references "GROUPS" (
    "GROUP_ID") on update no action on delete cascade

go

alter table "PREFERENCE_VALUES"
  add constraint "USERS_PREFERENCE_VALUES_FK1" foreign key (
    "USER_ID")
   references "USERS" (
    "USER_ID") on update no action on delete cascade

go

alter table "PREFERENCE_VALUES"
  add constraint "PREFERENCE_KEY_VALUES_FK1" foreign key (
    "PREFERENCE_ID")
   references "PREFERENCE_KEYS" (
    "PREFERENCE_ID") on update no action on delete cascade

go

alter table "DEP_AREA_ALLOWED_GRP"
  add constraint "GROUPS__GROUP_ID_FK1" foreign key (
    "GROUP_ID")
   references "GROUPS" (
    "GROUP_ID") on update no action on delete cascade

go

alter table "DEP_AREA_ALLOWED_GRP"
  add constraint "DEP_AREAS_AREA_ID_FK1" foreign key (
    "AREA_ID")
   references "DEP_AREAS_DEF" (
    "AREA_ID") on update no action on delete cascade

go

/* Trigger instead of foreign key constraint due to MSSQL limitations ("recursive" triggers) */
create trigger GROUP_MEMBERS_INSERT_TR on "GROUP_MEMBERS" after insert, update
  as
  if exists (select i."MEMBER_GROUP_ID" from INSERTED i 
    where i."MEMBER_GROUP_ID" is not null
    and not exists (select g."GROUP_ID" from "GROUPS" g where g."GROUP_ID" = i."MEMBER_GROUP_ID"))
  BEGIN
     RAISERROR ('Constraint: invalid MEMBER_GROUP_ID', 16, 2)
     ROLLBACK TRANSACTION
  END

go

/* Trigger instead of foreign key constraint due to MSSQL limitations ("recursive" triggers) */
create trigger GROUP_DELETE_TR on "GROUPS" after delete
	as
	Delete from "GROUP_MEMBERS" 
	where "MEMBER_GROUP_ID" in
	    (SELECT d."GROUP_ID"
	        from DELETED d 
	    );
	UPDATE "GROUPS"
	set "PRIMARY_GROUP_ID" = null 
	where "PRIMARY_GROUP_ID" in 
	   (SELECT d2."GROUP_ID"
	       from DELETED d2 
	   )

go

alter table "GROUP_MEMBERS"
  add constraint "GROUP_ID_FK2" foreign key (
    "GROUP_ID")
   references "GROUPS" (
    "GROUP_ID") on update no action on delete cascade

go

alter table "GROUP_MEMBERS"
  add constraint "USERS_GROUP_MEMBERS_FK1" foreign key (
    "MEMBER_USER_ID")
   references "USERS" (
    "USER_ID") on update no action on delete cascade

go

alter table "GROUP_MEMBERS" add constraint "GROUP_MEMBERS_XOR" check (			
	("MEMBER_USER_ID" is null and "MEMBER_GROUP_ID" is not null) 
	or 
	("MEMBER_USER_ID" is not null and "MEMBER_GROUP_ID" is null)
	or 
	("GROUP_ID" = '19e7e430-9997-11da-fbc4-0010ac110215')
)

go

alter table "USERS"
  add constraint "GROUPS_USERS_FK1" foreign key (
    "PRIMARY_GROUP_ID")
   references "GROUPS" (
    "GROUP_ID") on update no action on delete set null

go

/* Trigger instead of foreign key constraint due to MSSQL limitations ("recursive" triggers) */
create trigger GROUPS_PRIMARY_GROUP_UPDATE_TR on "GROUPS" after insert, update
	as
	if (select count(*) from "GROUPS" 
	      where "PRIMARY_GROUP_ID" not in (select "GROUP_ID" from "GROUPS")) > 0
	BEGIN
	   RAISERROR ('Constraint: invalid PRIMARY_GROUP_ID', 16, 3)
	   ROLLBACK TRANSACTION
	END

go

alter table "DEP_AREAS"
  add constraint "DEP_DIST_AREA_DIST_ID_FK1" foreign key (
    "DISTRIBUTION_ID")
   references "DEP_DISTRIBUTIONS" (
    "DISTRIBUTION_ID") on update no action on delete cascade
    
go

alter table "DEP_AREAS"
  add constraint "DEP_AREAS_DEF_FK1" foreign key (
    "AREA_ID")
   references "DEP_AREAS_DEF" (
    "AREA_ID") on update no action on delete cascade

go

alter table "DEP_DISTRIBUTION_CONTENTS"
  add constraint "DEP_DISTRIBUTIONS_DIST_ID_FK1" foreign key (
    "DISTRIBUTION_ID")
   references "DEP_DISTRIBUTIONS" (
    "DISTRIBUTION_ID") on update no action on delete cascade

go

alter table "DEP_DISTRIBUTION_CONTENTS"
  add constraint "DEP_PACKAGES_PACKAGE_ID_FK1" foreign key (
    "PACKAGE_ID")
   references "DEP_PACKAGES" (
    "PACKAGE_ID") on update no action on delete cascade

go

create view UTC_TIME as select GETUTCDATE() as TS;

go

/* ----------------- library --------------------- */

go

create table "LIB_ITEM_TYPES" ( 
	"TYPE_ID" char(36) not null,
	"LABEL" varchar(255) not null,
	"LABEL_PREFIX" varchar(255) not null,
	"DISPLAY_NAME" varchar(255) not null,
	"IS_CONTAINER" bit not null,
	"FILE_SUFFIX" varchar(255) null,
	"MIME_TYPE" varchar(255) null,
	primary key ("TYPE_ID")
)  

go

alter table "LIB_ITEM_TYPES" add constraint "LIB_ITEM_TYPES_CONSTRAINT" 
	unique ("LABEL", "LABEL_PREFIX")

go

create table "LIB_ITEMS" ( 
	"ITEM_ID" char(36) not null,
	"TITLE" nvarchar(256) not null,
	"DESCRIPTION" nvarchar(1000) null,
	"ITEM_TYPE" char(36) not null,
	"FORMAT_VERSION" varchar(50) null,
	"CREATED_BY" char(36) null,
	"CREATED" datetime not null,
	"MODIFIED_BY" char(36) null,
	"MODIFIED" datetime not null,
	"ACCESSED" datetime null,
	"CONTENT_SIZE" bigint not null constraint "LIB_ITEMS_CONTENT_SIZE_DF" default 0,
	"PARENT_ID" char(36) null, 
	"HIDDEN" bit not null,
	primary key ("ITEM_ID"),
	foreign key ("CREATED_BY") 
		references "USERS" ("USER_ID") on update set null on delete set null,
	foreign key ("MODIFIED_BY") 
		references "USERS" ("USER_ID") on update no action on delete no action,
	foreign key ("PARENT_ID") 
		references "LIB_ITEMS" ("ITEM_ID") on update no action on delete no action,
	foreign key ("ITEM_TYPE") 
		references "LIB_ITEM_TYPES" ("TYPE_ID") on update no action on delete no action
)

go

alter table "LIB_ITEMS" add constraint "LIB_ITEMS_PARENT_NEQ_ITEM" 
	check ("ITEM_ID" != "PARENT_ID")

go

create index "LIB_ITEM_INDEX1" 
	on "LIB_ITEMS" ("CREATED_BY")  
go

create index "LIB_ITEM_INDEX2" 
	on "LIB_ITEMS" ("MODIFIED_BY")  
go

create index "LIB_ITEM_INDEX3" 
	on "LIB_ITEMS" ("ITEM_TYPE")  
go

create index "LIB_ITEM_INDEX4" 
	on "LIB_ITEMS" ("TITLE")  
go

create index "LIB_ITEM_INDEX5" 
	on "LIB_ITEMS" ("PARENT_ID")  
go

/* Trigger instead of foreign key constraint due to MSSQL limitations ("recursive" triggers) */
create trigger "TR_LIB_ITEM_USER" on "USERS" instead of delete 
	as
	update "LIB_ITEMS" set "MODIFIED_BY" = null where "MODIFIED_BY" in (select "USER_ID" from "DELETED");
	delete from "USERS" where "USER_ID" in (select "USER_ID" from "DELETED");
	
go

create table "LIB_PROPERTIES" ( 
	"ITEM_ID" char(36) not null,
	"PROPERTY_NAME" nvarchar(150) not null,
	"PROPERTY_VALUE" nvarchar(256) not null,
	"PROPERTY_BLOB_VALUE" varbinary(max) null,
	constraint "FK_LIB_PROPERTIES_LIB_ITEM" foreign key ("ITEM_ID")
	 	references "LIB_ITEMS" ("ITEM_ID") on update no action on delete cascade
)

go

create index "LIB_PROPERTIES_INDEX" on "LIB_PROPERTIES" ("ITEM_ID", "PROPERTY_NAME", "PROPERTY_VALUE");

go

create table "LIB_PRINCIPAL_PROPS" ( 
  "ITEM_ID" char(36) not null,
  "USER_ID" char(36) null,
  "GROUP_ID" char(36) null,
  "PROPERTY_NAME" nvarchar(150) not null,
  "PROPERTY_VALUE_JSON" varbinary(max) null,
  constraint "FK_LPP_LIB_ITEMS" foreign key ("ITEM_ID")
    references "LIB_ITEMS" ("ITEM_ID") on delete cascade,
  constraint "FK_LPP_USERS" foreign key ("USER_ID")
    references "USERS" ("USER_ID") on delete cascade,
  constraint "FK_LPP_GROUPS" foreign key ("GROUP_ID")
    references "GROUPS" ("GROUP_ID") on delete cascade,
  constraint "LPP_UC1" 
    unique ("ITEM_ID", "USER_ID", "GROUP_ID", "PROPERTY_NAME") )

go

create index "LIB_PRINCIPAL_PROPS_IX2" on "LIB_PRINCIPAL_PROPS" (
  "USER_ID",
  "PROPERTY_NAME",
  "ITEM_ID")

go

create index "LIB_PRINCIPAL_PROPS_IX3" on "LIB_PRINCIPAL_PROPS" (
  "GROUP_ID",
  "PROPERTY_NAME",
  "ITEM_ID")

go

alter table "LIB_PRINCIPAL_PROPS" add constraint "LIB_PRINCIPAL_PROPS_XOR" check (      
  ("USER_ID" is null and "GROUP_ID" is not null) 
  or 
  ("USER_ID" is not null and "GROUP_ID" is null)
)

go

create table "LIB_WORDS" (
	"ITEM_ID" char(36) not null,
	"PROPERTY" nvarchar(150) not null,
	"WORD" nvarchar(256) not null,
	constraint "FK_LIB_WORDS_LIB_ITEM" foreign key ("ITEM_ID")
		references "LIB_ITEMS" ("ITEM_ID") on delete cascade ) 

go

create index "LIB_WORDS_INDEX" on "LIB_WORDS" ("ITEM_ID", "PROPERTY", "WORD");

go

/* Contains content types (e.g. text/xml) */
create table "LIB_CONTENT_TYPES" ( 
	"TYPE_ID" decimal(2,0) not null,
	"CONTENT_TYPE" varchar(50) not null,
	primary key ("TYPE_ID")
)  

go

/* Contains content encodings (e.g. zip) */
create table "LIB_CONTENT_ENCODINGS" ( 
	"ENCODING_ID" decimal(2,0) not null,
	"CONTENT_ENCODING" varchar(50) not null,
	primary key ("ENCODING_ID")
)  

go

/* Contains character encodings (e.g. utf-8) */
create table "LIB_CHARACTER_ENCODINGS" ( 
	"ENCODING_ID" decimal(2,0) not null,
	"CHARACTER_ENCODING" varchar(50) not null,
	primary key ("ENCODING_ID")
)

go

/* Contains actual library content */
create table "LIB_DATA" ( 
	"ITEM_ID" char(36) not null,
	"CONTENT_TYPE" decimal(2,0) null,
	"CONTENT_ENCODING" decimal(2,0) null,
	"CHARACTER_ENCODING" decimal(2,0) null,
	"DATA" varbinary(max) not null,
	primary key ("ITEM_ID"),
	foreign key ("ITEM_ID")
	 	references "LIB_ITEMS" ("ITEM_ID") 
	 	on update no action on delete cascade,
	foreign key ("CONTENT_TYPE")
	 	references "LIB_CONTENT_TYPES" ("TYPE_ID") 
		on update no action on delete no action,
	foreign key ("CONTENT_ENCODING")
	 	references "LIB_CONTENT_ENCODINGS" ("ENCODING_ID") 
	 	on update no action on delete no action,
	foreign key ("CHARACTER_ENCODING")
		references "LIB_CHARACTER_ENCODINGS" ("ENCODING_ID") 
		on update no action on delete no action
) 

go

create table "LIB_ACCESS" ( 
	"ITEM_ID" char(36) not null,
	"USER_ID" char(36) null,
    "GROUP_ID" char(36) null,
	"PERMISSION" char(1) not null,
	foreign key ("ITEM_ID")
	 	references "LIB_ITEMS" ("ITEM_ID") 
	 	on update no action on delete cascade,
	foreign key ("USER_ID")
	 	references "USERS" ("USER_ID") 
	 	on update no action on delete cascade,
	foreign key ("GROUP_ID")
	 	references "GROUPS" ("GROUP_ID") 
	 	on update no action on delete cascade
)
  
go

create index "LIB_ACCESS_INDEX1" 
	on "LIB_ACCESS" ("USER_ID")  
go

create index "LIB_ACCESS_INDEX2" 
	on "LIB_ACCESS" ("GROUP_ID")  
go


alter table "LIB_ACCESS"
	add constraint "LIB_ACCESS_UC1" unique ("ITEM_ID", "USER_ID", "GROUP_ID", "PERMISSION")   

go

alter table "LIB_ACCESS" add constraint "LIB_ACCESS_XOR" check (	
	("USER_ID" is null and "GROUP_ID" is not null) 
	or 
	("USER_ID" is not null and "GROUP_ID" is null)
)	

go

create table "LIB_RESOLVED_DEPEND" (
	"DEPENDENT_ID" char(36) not null,
  	"REQUIRED_ID" char(36) not null,
  	"DESCRIPTION" nvarchar(1000) null,
  	"CASCADING_DELETE" bit not null,
  	"ORIGINAL_REQUIRED_ID" char(36) null,
  	primary key ("DEPENDENT_ID", "REQUIRED_ID"),
  	foreign key ("DEPENDENT_ID")
   		references "LIB_ITEMS" ("ITEM_ID") 
   		on update no action on delete cascade,
	foreign key ("REQUIRED_ID")
   		references "LIB_ITEMS" ("ITEM_ID") 
   		on update no action on delete no action
)

go

create index "LIB_RESOLVED_INDEX1" 
	on "LIB_RESOLVED_DEPEND" ("DEPENDENT_ID")  
	
go

create index "LIB_RESOLVED_INDEX2" 
	on "LIB_RESOLVED_DEPEND" ("REQUIRED_ID")  
	
go

alter table "LIB_RESOLVED_DEPEND" add constraint "RESOLVED_DEP_NEQ_REQ"
	check ("DEPENDENT_ID" != "REQUIRED_ID")

go

create table "LIB_UNRESOLVED_DEPEND" (
  	"DEPENDENT_ID" char(36) not null,
  	"REQUIRED_ID" char(36) not null,
	"DESCRIPTION" nvarchar(1000) null,
  	"CASCADING_DELETE" bit not null,
  	"ORIGINAL_REQUIRED_ID" char(36) null,
  	primary key ("DEPENDENT_ID", "REQUIRED_ID"),
  	foreign key ("DEPENDENT_ID")
   		references "LIB_ITEMS" ("ITEM_ID") 
   		on update no action on delete cascade
)

go

create index "LIB_UNRESOLVED_INDEX1" 
	on "LIB_UNRESOLVED_DEPEND" ("DEPENDENT_ID")  
	
go

create index "LIB_UNRESOLVED_INDEX2" 
	on "LIB_UNRESOLVED_DEPEND" ("REQUIRED_ID")  
	
go

alter table "LIB_UNRESOLVED_DEPEND" add constraint "UNRESOLVED_DEP_NEQ_REQ"
	check ("DEPENDENT_ID" != "REQUIRED_ID")

go

create table "LIB_APPLICATIONS" (
	"APPLICATION_ID" tinyint not null,
	"APPLICATION_NAME" varchar(256) not null,
	primary key ("APPLICATION_ID") );

go

create unique index "UK_LIB_APPLICATIONS_IDX" on "LIB_APPLICATIONS" ("APPLICATION_NAME");

go

create table "LIB_VISIBLE_TYPES" (
	"TYPE_ID" char(36) not null,
	"APPLICATION_ID" tinyint not null,
	primary key ("TYPE_ID", "APPLICATION_ID"),
	foreign key ("TYPE_ID")
		references "LIB_ITEM_TYPES" ("TYPE_ID") on delete cascade, 
	foreign key ("APPLICATION_ID")
		references "LIB_APPLICATIONS" ("APPLICATION_ID") on delete cascade );

go

create procedure usp_copyItem 
  @oldId char(36), 
  @newId char(36), 
  @parentId char(36), 
  @caller char(36), 
  @newTitle nvarchar(256) 
as 
begin 
	set nocount on; 
	declare @timeOfUpdate datetime; 
	set @timeOfUpdate = (select convert(varchar(23), getutcdate(), 121)); 

	if (@newTitle is null) 
		insert into LIB_ITEMS (ITEM_ID, TITLE, DESCRIPTION, ITEM_TYPE, FORMAT_VERSION, CREATED_BY, CREATED, MODIFIED_BY, 
		  MODIFIED, CONTENT_SIZE, PARENT_ID, HIDDEN) 
		select @newId as ITEM_ID, 
		  TITLE, DESCRIPTION, ITEM_TYPE, FORMAT_VERSION, CREATED_BY, CREATED, 
		  @caller as MODIFIED_BY, 
		  @timeOfUpdate as MODIFIED, 
		  CONTENT_SIZE, 
		  @parentId as PARENT_ID, 
		  HIDDEN 
		from LIB_ITEMS original 
		where original.ITEM_ID = @oldId; 
	else 
		insert into LIB_ITEMS (ITEM_ID, TITLE, DESCRIPTION, ITEM_TYPE, FORMAT_VERSION, CREATED_BY, CREATED, MODIFIED_BY, 
		  MODIFIED, CONTENT_SIZE, PARENT_ID, HIDDEN) 
		select @newId as ITEM_ID, 
		  @newTitle as TITLE, 
		  DESCRIPTION, ITEM_TYPE, FORMAT_VERSION, CREATED_BY, CREATED, 
		  @caller as MODIFIED_BY, 
		  @timeOfUpdate as MODIFIED, 
		  CONTENT_SIZE, 
		  @parentId as PARENT_ID, 
		  HIDDEN 
		from LIB_ITEMS original 
		where original.ITEM_ID = @oldId; 

	insert into #LIB_COPY_MAPPING (ORIGINAL_ID, COPY_ID) values (@oldId, @newId); 
 
end;

go

create procedure usp_finishCopy
as
begin
	set nocount on;
	
	-- Content
	insert into LIB_DATA (ITEM_ID, CONTENT_TYPE, CONTENT_ENCODING, CHARACTER_ENCODING, DATA) 
		select cm.COPY_ID as ITEM_ID, CONTENT_TYPE, CONTENT_ENCODING, CHARACTER_ENCODING, DATA 
		from LIB_DATA original, #LIB_COPY_MAPPING cm 
		where original.ITEM_ID = cm.ORIGINAL_ID;

	-- Properties
	insert into LIB_PROPERTIES (ITEM_ID, PROPERTY_NAME, PROPERTY_VALUE, PROPERTY_BLOB_VALUE) 
		select cm.COPY_ID as ITEM_ID, PROPERTY_NAME, PROPERTY_VALUE, PROPERTY_BLOB_VALUE
		from LIB_PROPERTIES original, #LIB_COPY_MAPPING cm 
		where original.ITEM_ID = cm.ORIGINAL_ID;
	
	-- Permissions
	insert into LIB_ACCESS (ITEM_ID, USER_ID, GROUP_ID, PERMISSION) 
		select cm.COPY_ID as ITEM_ID, USER_ID, GROUP_ID, PERMISSION 
		from LIB_ACCESS original, #LIB_COPY_MAPPING cm 
		where original.ITEM_ID = cm.ORIGINAL_ID;

	-- Unresolved dependencies
	insert into LIB_UNRESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
		select cm.COPY_ID as DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID 
		from LIB_UNRESOLVED_DEPEND original, #LIB_COPY_MAPPING cm 
		where original.DEPENDENT_ID = cm.ORIGINAL_ID;

	-- Resolved dependencies where the required items also have been copied and there is no original required ID
	insert into LIB_RESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
		select 
		dep.COPY_ID as DEPENDENT_ID, 
		req.COPY_ID as REQUIRED_ID, 
		original.DESCRIPTION, 
		original.CASCADING_DELETE,
		original.REQUIRED_ID 
		from LIB_RESOLVED_DEPEND original, #LIB_COPY_MAPPING dep, #LIB_COPY_MAPPING req
		where original.DEPENDENT_ID = dep.ORIGINAL_ID
		and original.REQUIRED_ID = req.ORIGINAL_ID
		and ORIGINAL_REQUIRED_ID is null;

	-- Resolved dependencies where the required items also have been copied and there is an original required ID
	insert into LIB_RESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
		select 
		dep.COPY_ID as DEPENDENT_ID, 
		req.COPY_ID as REQUIRED_ID, 
		original.DESCRIPTION, 
		original.CASCADING_DELETE,
		original.ORIGINAL_REQUIRED_ID
		from LIB_RESOLVED_DEPEND original, #LIB_COPY_MAPPING dep, #LIB_COPY_MAPPING req
		where original.DEPENDENT_ID = dep.ORIGINAL_ID
		and original.REQUIRED_ID = req.ORIGINAL_ID
		and ORIGINAL_REQUIRED_ID is not null;
    
	-- Resolved dependencies where the required items has not been copied
	insert into LIB_RESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
		select 
		dep.COPY_ID as DEPENDENT_ID, 
		original.REQUIRED_ID, 
		original.DESCRIPTION, 
		original.CASCADING_DELETE, 
		original.ORIGINAL_REQUIRED_ID
		from LIB_RESOLVED_DEPEND original, #LIB_COPY_MAPPING dep
		where original.DEPENDENT_ID = dep.ORIGINAL_ID
		and not exists (select 1 from #LIB_COPY_MAPPING where ORIGINAL_ID = original.REQUIRED_ID);
	
	-- Return all copied items
    select i.ITEM_ID, i.TITLE, i.DESCRIPTION, i.ITEM_TYPE, i.FORMAT_VERSION, i.CREATED_BY, i.CREATED, 
		i.MODIFIED_BY, i.MODIFIED, i.ACCESSED, i.CONTENT_SIZE, i.PARENT_ID, i.HIDDEN
		from LIB_ITEMS i, #LIB_COPY_MAPPING cm where i.ITEM_ID = cm.COPY_ID;

	-- Explicitly drop the temporary table
	drop table #LIB_COPY_MAPPING;

end;

go

create procedure usp_moveItem (
	@itemId char(36), 
	@newParentId char(36),
	@caller char(36),
	@newTitle nvarchar(256)) as
begin
	set nocount on;
	
	declare @timeOfUpdate datetime;
	set @timeOfUpdate = (select convert(varchar(23), getutcdate(), 121));

	if (@newTitle is null)
		update LIB_ITEMS set MODIFIED_BY = @caller, MODIFIED = @timeOfUpdate,  PARENT_ID = @newParentId 
			where ITEM_ID = @itemId;
	else
		update LIB_ITEMS set TITLE = @newTitle, MODIFIED_BY = @caller, MODIFIED = @timeOfUpdate, PARENT_ID = @newParentId 
			where ITEM_ID = @itemId;
end;

go

create procedure usp_verifyAccess (
	@itemId char(36), 
	@caller char(36),
	@permission char(1),
	@administrationEnabled bit,
	@hasAccess int output) as
begin
	set nocount on;

	-- Pessimistic approach - assume that the called does not have sufficient access
	set @hasAccess = 0;

	-- Determine to which groups the user belongs
	declare @GROUP_MEMBERSHIPS table (GROUP_ID char(36) collate database_default);
	with ALL_GROUPS as 
		(
        select gm.GROUP_ID from GROUP_MEMBERS_VIEW gm
          where gm.MEMBER_USER_ID = @caller
        union all
        select gm.GROUP_ID from GROUP_MEMBERS_VIEW gm, ALL_GROUPS cte
          where cte.GROUP_ID = gm.MEMBER_GROUP_ID
		)
	insert into @GROUP_MEMBERSHIPS select GROUP_ID from ALL_GROUPS;

	if (@administrationEnabled = 1) and exists (select 1 from @GROUP_MEMBERSHIPS 
			where GROUP_ID in (select GROUP_ID from GROUPS where GROUP_NAME in (N'Library Administrator', N'Administrator') and DOMAIN_NAME = N'SPOTFIRE'))
		-- The user is a library administrator and therefore has full access to everything
		set @hasAccess = 1;
	else
		begin
			-- The user is not a library administrator so we should determine if the user has sufficient permissions on
			-- the item (considering permission inheritance between items and all groups to which the user may belong)
			with PERMISSIONS_ON_ITEM as
			(
				select ITEM_ID as PARENT_ID from LIB_ITEMS where ITEM_ID = @itemId
				union all
				select i.PARENT_ID from PERMISSIONS_ON_ITEM poi, LIB_ITEMS i
				where poi.PARENT_ID = i.ITEM_ID
				and not exists (select 1 from LIB_ACCESS acl where acl.ITEM_ID = poi.PARENT_ID)
			) 
			select @hasAccess = 1
				from LIB_ACCESS acl, PERMISSIONS_ON_ITEM apa, @GROUP_MEMBERSHIPS gr
				where acl.ITEM_ID = apa.PARENT_ID
				and (acl.USER_ID = @caller or acl.GROUP_ID = gr.GROUP_ID)
				and acl.PERMISSION = @permission;
		end
end;

go

create procedure usp_verifyWriteAccessOnDescendants (
  @itemId char(36), 
  @caller char(36),
  @administrationEnabled bit) as
begin
  set nocount on;
  
  declare c1 cursor local fast_forward for
    with CTE (ITEM_ID, PARENT_ID) as
    (
      select ITEM_ID, PARENT_ID 
      from LIB_ITEMS 
      where ITEM_ID = @itemId 
      union all
      select item.ITEM_ID, item.PARENT_ID 
      from LIB_ITEMS item, CTE parent 
      where item.PARENT_ID = parent.ITEM_ID
    ) 
    select PARENT_ID from CTE;

  declare @descendant char(36);
  declare @hasAccess int;

  -- Determine to which groups the user belongs
  declare @GROUP_MEMBERSHIPS table (GROUP_ID char(36) collate database_default);
  with ALL_GROUPS as 
    (
    select gm.GROUP_ID from GROUP_MEMBERS_VIEW gm
      where gm.MEMBER_USER_ID = @caller
    union all
    select gm.GROUP_ID from GROUP_MEMBERS_VIEW gm, ALL_GROUPS cte
      where cte.GROUP_ID = gm.MEMBER_GROUP_ID
    )
  insert into @GROUP_MEMBERSHIPS select distinct GROUP_ID from ALL_GROUPS;

  if (@administrationEnabled = 1) and exists (select 1 from @GROUP_MEMBERSHIPS 
    where GROUP_ID in (select GROUP_ID from GROUPS where GROUP_NAME in (N'Library Administrator', N'Administrator') and DOMAIN_NAME = N'SPOTFIRE'))
    -- The user is a library administrator and therefore has full access to everything
    return;

  -- The user is not a library administrator so we should determine if the user has sufficient permissions on
  -- the item (considering permission inheritance between items and all groups to which the user may belong)
  open c1;
  fetch next from c1 into @descendant;
  while @@fetch_status = 0
  begin
    -- Pessimistic approach - assume that the caller does not have sufficient access
    set @hasAccess = 0;

    with PERMISSIONS_ON_ITEM as
      (
        select ITEM_ID as PARENT_ID from LIB_ITEMS where ITEM_ID = @descendant
        union all
        select i.PARENT_ID from PERMISSIONS_ON_ITEM poi, LIB_ITEMS i
        where poi.PARENT_ID = i.ITEM_ID
        and not exists (select 1 from LIB_ACCESS acl where acl.ITEM_ID = poi.PARENT_ID)
      ) 
      select @hasAccess = 1
        from LIB_ACCESS acl, PERMISSIONS_ON_ITEM apa, @GROUP_MEMBERSHIPS gr
        where acl.ITEM_ID = apa.PARENT_ID
        and (acl.USER_ID = @caller or acl.GROUP_ID = gr.GROUP_ID)
        and acl.PERMISSION = 'W';
    if (@hasAccess = 0)
    begin;
      raiserror('ERR-50002 - Insufficient access.', 16, 1);
      return;
    end;
    fetch next from c1 into @descendant;
  end
  close c1;
  deallocate c1;   
end;

go

create procedure usp_insertDepencency
  @dependentId char(36), 
  @requiredId char(36),
  @description nvarchar(1000),
  @cascadingDelete bit,
  @originalRequiredId char(36)
as
begin
	set nocount on;
	
	if exists (select 1 from LIB_ITEMS where ITEM_ID = @requiredId)
		insert into LIB_RESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
			values (@dependentId, @requiredId, @description, @cascadingDelete, @originalRequiredId);
	else
		insert into LIB_UNRESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
			values (@dependentId, @requiredId, @description, @cascadingDelete, @originalRequiredId);  
end;

go

create procedure usp_insertItem ( 
	@newItemId char(36), 
	@newTitle nvarchar(256), 
	@newDescription nvarchar(1000), 
	@newItemType char(36), 
	@newFormatVersion varchar(50), 
	@newContentSize bigint, 
	@newParentId char(36), 
	@newHidden bit, 
	@caller char(36),
	@verifyAccess bit,
	@administrationEnabled bit) as 
begin 
	set nocount on; 

	-- Verify that the parent exists 
	if not exists (select 1 from LIB_ITEMS where ITEM_ID = @newParentId) 
		raiserror('ERR-50005 - The item with ID %s does not exist.', 16, 1, @newParentId); 

	-- Verify access 
	if (@verifyAccess = 1)
	begin
		declare @hasAccess int;
		exec usp_verifyAccess @newParentId, @caller, 'W', @administrationEnabled, @hasAccess output;
		if (@hasAccess = 0) 
			raiserror('ERR-50002 - Insufficient access.', 16, 1); 
	end

	-- Verify that the parent is a container item 
	if exists (select 1 from LIB_ITEM_TYPES it, LIB_ITEMS i where i.ITEM_TYPE = it.TYPE_ID 
			and i.ITEM_ID = @newParentId and it.IS_CONTAINER = '0') 
		raiserror('ERR-50004 - Illegal argument. %s', 16, 1, 'Items may only be placed in container items.'); 

	-- Verify that the ID is unique 
	if exists (select 1 from LIB_ITEMS where ITEM_ID = @newItemId) 
		raiserror('ERR-50001 - A item with %s %s already exists.', 16, 1, 'ID', @newItemId); 

	-- Verify that the title-type-parent combination is unique 
	if exists (select 1 from LIB_ITEMS where TITLE = @newTitle and ITEM_TYPE = @newItemType and 
			PARENT_ID = @newParentId) 
		raiserror('ERR-50001 - A item with %s %s already exists.', 16, 1, 'title', @newTitle); 

	-- Verify that the maximum folder depth is not exceeded 
	declare @lvl int; 
	with CTE (LVL, ITEM_ID) as 
		(select 1 as LVL,  PARENT_ID from LIB_ITEMS where ITEM_ID = @newParentId 
		union all 
		select cte.LVL + 1, i.PARENT_ID from LIB_ITEMS i, CTE cte 
		where cte.ITEM_ID = i.ITEM_ID) 
	select @lvl = max(LVL) from CTE; 
	if (@lvl > 99) 
		raiserror('ERR-50003 - Maximum folder depth exceeded. Maximum allowed is 100.', 16, 1); 

	-- Store the current timestamp 
	declare @timeOfInsertion datetime; 
	set @timeOfInsertion = (select convert(varchar(23), getutcdate(), 121)); 

	-- Insert the item 
	insert into LIB_ITEMS (ITEM_ID, TITLE, DESCRIPTION, ITEM_TYPE, FORMAT_VERSION, CREATED_BY, 
		CREATED, MODIFIED_BY, MODIFIED, CONTENT_SIZE, PARENT_ID, HIDDEN) 
		values (@newItemId, @newTitle, @newDescription, @newItemType, @newFormatVersion, @caller, @timeOfInsertion, 
		@caller, @timeOfInsertion, @newContentSize, @newParentId, @newHidden); 

	-- Move any unresolved dependencies upon the inserted item into the set of resolved dependencies
	insert into LIB_RESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
	( 
		select DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID 
		from LIB_UNRESOLVED_DEPEND 
		where REQUIRED_ID = @newItemId 
	); 
	delete from LIB_UNRESOLVED_DEPEND where REQUIRED_ID = @newItemId; 

end;

go

create procedure usp_updateItem ( 
	@itemId char(36), 
	@newTitle nvarchar(256), 
	@newDescription nvarchar(1000), 
	@newFormatVersion varchar(50), 
	@newHidden bit, 
	@caller char(36),
	@verifyAccess bit,
	@administrationEnabled bit) as 
begin 
	set nocount on; 

	declare @parentId char(36); 
	declare @itemType char(36); 
	declare @contentSize bigint; 
	declare @timeOfUpdate datetime; 

	-- Verify that the item exists 
	if not exists (select 1 from LIB_ITEMS where ITEM_ID = @itemId) 
		raiserror('ERR-50005 - The item with ID %s does not exist.', 16, 1, @itemId); 

	 -- Fetch and store the parent ID, the item type and the current timestamp 
	select @parentId = PARENT_ID, @itemType = ITEM_TYPE, @timeOfUpdate = convert(varchar(23), getutcdate(), 121) 
		from LIB_ITEMS where ITEM_ID = @itemId; 

	-- Fetch the content size, if present (0 otherwise) 
	select @contentSize = datalength(DATA) from LIB_DATA where LIB_DATA.ITEM_ID = @itemId; 
	if (@contentSize is null) 
		set @contentSize = 0; 

	-- Verify access 
	if (@verifyAccess = 1)
	begin
		declare @hasAccess int; 
		exec usp_verifyAccess @parentId, @caller, 'W', @administrationEnabled, @hasAccess output; 
		if (@hasAccess = 0) 
			raiserror('ERR-50002 - Insufficient access.', 16, 1); 
	end
 
	-- Verify that the title-type-parent combination is unique 
	if exists (select 1 from LIB_ITEMS where TITLE = @newTitle and ITEM_TYPE = @itemType and 
			PARENT_ID = @parentId and ITEM_ID != @itemId) 
		raiserror('ERR-50001 - A item with %s %s already exists.', 16, 1, 'title', @newTitle); 

	-- Update the item 
	update LIB_ITEMS set TITLE = @newTitle, DESCRIPTION = @newDescription, FORMAT_VERSION = @newFormatVersion, 
		MODIFIED_BY = @caller, MODIFIED = @timeOfUpdate, CONTENT_SIZE = @contentSize, HIDDEN = @newHidden where ITEM_ID = @itemId; 

end;

go

create procedure usp_updateExternallyStoredItem ( 
  @itemId char(36), 
  @newTitle nvarchar(256), 
  @newDescription nvarchar(1000), 
  @newFormatVersion varchar(50), 
  @newHidden bit, 
  @caller char(36),
  @verifyAccess bit,
  @administrationEnabled bit,
  @contentSize bigint) as 
begin 
  set nocount on; 

  declare @parentId char(36); 
  declare @itemType char(36); 
  declare @timeOfUpdate datetime; 

  -- Verify that the item exists 
  if not exists (select 1 from LIB_ITEMS where ITEM_ID = @itemId) 
    raiserror('ERR-50005 - The item with ID %s does not exist.', 16, 1, @itemId); 

   -- Fetch and store the parent ID, the item type and the current timestamp 
  select @parentId = PARENT_ID, @itemType = ITEM_TYPE, @timeOfUpdate = convert(varchar(23), getutcdate(), 121) 
    from LIB_ITEMS where ITEM_ID = @itemId; 

  -- Verify access 
  if (@verifyAccess = 1)
  begin
    declare @hasAccess int; 
    exec usp_verifyAccess @parentId, @caller, 'W', @administrationEnabled, @hasAccess output; 
    if (@hasAccess = 0) 
      raiserror('ERR-50002 - Insufficient access.', 16, 1); 
  end
 
  -- Verify that the title-type-parent combination is unique 
  if exists (select 1 from LIB_ITEMS where TITLE = @newTitle and ITEM_TYPE = @itemType and 
      PARENT_ID = @parentId and ITEM_ID != @itemId) 
    raiserror('ERR-50001 - A item with %s %s already exists.', 16, 1, 'title', @newTitle); 

  -- Update the item 
  if (@contentSize = 0)
    update LIB_ITEMS set TITLE = @newTitle, DESCRIPTION = @newDescription, FORMAT_VERSION = @newFormatVersion, 
      MODIFIED_BY = @caller, MODIFIED = @timeOfUpdate, HIDDEN = @newHidden where ITEM_ID = @itemId;
  else
    update LIB_ITEMS set TITLE = @newTitle, DESCRIPTION = @newDescription, FORMAT_VERSION = @newFormatVersion, 
      MODIFIED_BY = @caller, MODIFIED = @timeOfUpdate, CONTENT_SIZE = @contentSize, HIDDEN = @newHidden where ITEM_ID = @itemId;

end;

go

create procedure pathToGuid
    @path nvarchar(4000),
    @itemType char(36),
    @rootGuid char(36)
as
begin
  set nocount on;

      -- Splits the path string into a sequence of elements and stores each element
      -- together with its level in the path
      create table #PATH_TABLE
      (
        ELEMENT nvarchar(256) collate database_default,
        LVL int
      )

      declare @ROOT_END int;
      select @ROOT_END = charindex('/', @path, 0) + 1;
      with STRING_CTE as
      (
        select 0 as START_INDEX, @ROOT_END as END_INDEX,
          0 as START_PARENT, @ROOT_END as END_PARENT, 0 as LVL

        union all

        select cte.END_INDEX, charindex('/', @path, cte.END_INDEX) + 1,
          cte.START_INDEX, cte.END_INDEX, cte.LVL + 1
        from STRING_CTE cte
        where END_INDEX > START_INDEX
      )
      insert into #PATH_TABLE
      select convert(nvarchar(256),
        substring(@path, START_INDEX,
          case when END_INDEX > 1
            then END_INDEX - START_INDEX - 1
          else
            len(@path) - START_INDEX + 1 end))
        as ELEMENT ,
        LVL
      from STRING_CTE where START_INDEX > 0;

      declare @MAXLVL int;
      select @MAXLVL = (select max(LVL) from #PATH_TABLE);

      -- First selects the root, then uses this information to find the child
      -- which has the root as parent and the next path element as title.
      -- This procedure is repeated until no more matches are found
      with PATH_CTE (ITEM_ID, TITLE, ITEM_TYPE, LVL) as
      (
        -- start from the root, use dummys for other than ITEM_ID
        select   @rootGuid, cast('foo' as nvarchar(256)), cast('foo' as char(36)), 1
      
        union all

        select item.ITEM_ID, item.TITLE, item.ITEM_TYPE, pth.LVL
        from LIB_ITEMS item, PATH_CTE cte, #PATH_TABLE pth
        where item.PARENT_ID = cte.ITEM_ID            -- must be a child of the node from the previous level
        and item.TITLE = pth.ELEMENT            -- and have a title that matches...
        and pth.LVL = cte.LVL + 1             -- ...the next element of the path
      )
      select cte.ITEM_ID
      from PATH_CTE cte
      where cte.LVL =@MAXLVL -- must be a child of the right most element of the parent path
      and cte.ITEM_TYPE = @itemType

end;

go



create procedure usp_deleteItem 
	@itemId char(36), 
	@caller char(36),
	@verifyAccess bit,
	@administrationEnabled bit,
	@allowUnresolvedDependencies bit
as
begin
	set nocount on;

	-- If the item has already been deleted there is nothing more to do
	if not exists (select 1 from LIB_ITEMS where ITEM_ID = @itemId)
		return;

	-- Verify access
	if (@verifyAccess = 1)
		exec usp_verifyWriteAccessOnDescendants @itemId, @caller, @administrationEnabled;

	-- Save the parent id
	declare @parentId char(36);
	set @parentId = (select PARENT_ID from LIB_ITEMS where ITEM_ID = @itemId);
	if (@parentId is null)
		raiserror('ERR-50004 - Illegal argument. %s', 16, 1, 'Cannot delete the root item.');

	-- Fetch all descendants
	declare @descendants table (DESCENDANT_ID char(36));
	with CTE (ITEM_ID, PARENT_ID) as
		(
			select ITEM_ID, PARENT_ID 
			from LIB_ITEMS 
			where ITEM_ID = @itemId 
			union all
			select item.ITEM_ID, item.PARENT_ID 
			from LIB_ITEMS item, CTE parent 
			where item.PARENT_ID = parent.ITEM_ID
		) 
	insert into @descendants (DESCENDANT_ID) select ITEM_ID from CTE;
	insert into #descendants (DESCENDANT_ID) select DESCENDANT_ID from @descendants;

	-- If creating dangling references is disallowed we need to verify that no dependencies upon the items 
	-- being deleted exists. 
	if (@allowUnresolvedDependencies = 0) 
		if exists (select 1	from LIB_RESOLVED_DEPEND rd, @descendants ds
				where rd.CASCADING_DELETE = 0
				and rd.REQUIRED_ID = ds.DESCENDANT_ID)
			raiserror('ERR-50006 - Dependencies without cascading delete found.', 16, 1);

	-- Move any dependency declarations, with non-cascading delete, upon the item being deleted 
	-- and all of its descendants from the set of resolved dependencies to the set of unresolved 
	-- dependencies.
	insert into LIB_UNRESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
		(
			select DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID 
			from LIB_RESOLVED_DEPEND 
			where CASCADING_DELETE = 0 
			and REQUIRED_ID in (select DESCENDANT_ID from @descendants)
		);
				
	-- Delete all dependent items with cascading delete
	declare @dependentItem char(36);
	declare c1 cursor local fast_forward for
		select DEPENDENT_ID 
		from LIB_RESOLVED_DEPEND 
		where CASCADING_DELETE = 1
		and REQUIRED_ID in (select DESCENDANT_ID from @descendants)
		except (select DESCENDANT_ID from @descendants);
	open c1;
	fetch next from c1 into @dependentItem;
	while @@fetch_status = 0
	begin
		exec usp_deleteItem @dependentItem, @caller, @verifyAccess, @administrationEnabled, @allowUnresolvedDependencies;
		fetch next from c1 into @dependentItem;
	end
	close c1;
	deallocate c1;
				
	-- Delete all declarations of depencencies upon the item and all of its descendants
	delete from LIB_RESOLVED_DEPEND where REQUIRED_ID in (select DESCENDANT_ID from @descendants);

	-- Delete the item itself and any descendants
	delete from LIB_ITEMS where ITEM_ID in (select DESCENDANT_ID from @descendants);

	-- Touch the parent
	declare @timeOfUpdate datetime;
	set @timeOfUpdate = (select convert(varchar(23), getutcdate(), 121));
	update LIB_ITEMS set MODIFIED_BY = @caller, MODIFIED = @timeOfUpdate where ITEM_ID = @parentId;
end;

go

create procedure usp_finishDelete
as
begin
  set nocount on;

  -- Return the items that have been deleted
  select * from #descendants;

  -- Drop the temporary table
  drop table #descendants;
end;

go

/* ----------------- configuration --------------------- */

create table SERVER_CONFIGURATIONS (
    CONFIG_HASH char(40) not null,
    CONFIG_DATE datetime not null,
    CONFIG_VERSION varchar(50) not null,
    CONFIG_DESCRIPTION nvarchar(1000) not null,
    CONFIG_CONTENT varbinary(max) not null, 
    constraint PK_SERVER_CONFIGURATIONS primary key (CONFIG_HASH) )

go

create table CONFIG_HISTORY (
    CONFIG_HASH char(40) not null,
    CONFIG_DATE datetime not null,
    CONFIG_COMMENT nvarchar(1000) not null,
    constraint PK_CONFIG_HISTORY PRIMARY KEY (CONFIG_HASH, CONFIG_DATE),
    constraint FK_CONFIG_HISTORY_CONFIG_HASH foreign key (CONFIG_HASH)
      references SERVER_CONFIGURATIONS (CONFIG_HASH) on delete cascade )

go

/* ----------------- JMX --------------------- */

create table "JMX_USERS" (
  "USER_NAME" nvarchar(200) not null,
  "PASSWORD_HASH" varchar(150) not null,
  "ACCESS_LEVEL" varchar(20) not null,
  constraint "JMX_USERS_PK" primary key ("USER_NAME"))

go

/* ----------------- nodes --------------------- */
create table SITES (
   SITE_ID char(36) not null,
   NAME nvarchar(200) not null,
   PROPERTIES_JSON varbinary(max) null,
   constraint PK_SITES primary key (SITE_ID)
)

go

create unique index SITES_NAME_INDEX on SITES(NAME)

go

create table NODES(
    ID char(36) NOT NULL,
    DEPLOYMENT_AREA char(36),
    IS_ONLINE smallint,
    PLATFORM varchar(36),
    PORT char(5) NOT NULL,
    CLEAR_TEXT_PORT char(5) DEFAULT 0,
    PRIMUS_CAPABLE smallint,  
    BUNDLE_VERSION varchar(200),
    PRODUCT_VERSION varchar(200),
    SITE_ID char(36) not null,
    constraint PK_NODES primary key (ID),
    constraint FK_NODES_SITE_ID foreign key (SITE_ID) references SITES (SITE_ID)
)
go

alter table NODES add constraint FK_NODES_AREA_ID foreign key(DEPLOYMENT_AREA) references DEP_AREAS_DEF(AREA_ID) on delete set null
go

CREATE INDEX "NODES_PRIMUS_CAPABLE" ON NODES("PRIMUS_CAPABLE")
go

CREATE INDEX "NODES_PRIMUS_CAPABLE_ONLINE" ON NODES("PRIMUS_CAPABLE", "IS_ONLINE")
go

CREATE INDEX "NODES_ONLINE" ON NODES("IS_ONLINE")
go

CREATE INDEX "NODES_SITES" ON NODES("SITE_ID")
go

create table NODE_SERVER_INFO(
   NODE_ID char(36) NOT NULL,
   SERVERNAME varchar(200) NOT NULL,
   PRIORITY smallint
)
go

alter table NODE_SERVER_INFO add constraint FK_NODE_SERVER_INFO_ID_NODES foreign key(NODE_ID) references NODES(ID) on delete cascade
go

CREATE INDEX "NODE_SERVER_INFO_NODE_ID" on NODE_SERVER_INFO ("NODE_ID")
go

CREATE INDEX "NODE_SERVER_INFO_ID_PRIO" ON NODE_SERVER_INFO("NODE_ID", "PRIORITY")
go

/* ----------------- server life cycle events --------------------- */

create table LIFECYCLE_EVENTS (
    SERVER_NAME varchar(250) not null,
    SERVER_IP varchar(100) not null,
    SERVER_VERSION varchar(250) not null,
    EVENT_DATE datetime not null,
    EVENT_NAME varchar(250) not null,
    IS_PRIMUS bit not null,
    IS_SITE_PRIMUS bit not null,
    NODE_ID char(36) null,
    constraint PK_LIFECYCLE_EVENTS primary key ( EVENT_NAME, EVENT_DATE, SERVER_NAME ),
    constraint FK_LIFECYCLE_EVENTS_NODE_ID foreign key (NODE_ID) references NODES (ID) on delete set null
)

go

CREATE INDEX "LIFECYCLE_EVENTS_PRIMUS" ON LIFECYCLE_EVENTS("IS_PRIMUS")
go

CREATE INDEX "LIFECYCLE_EVENTS_SITE_PRIMUS" ON LIFECYCLE_EVENTS("IS_SITE_PRIMUS")
go

CREATE INDEX "LIFECYCLE_EVENTS_EVENT_NAME" ON LIFECYCLE_EVENTS("EVENT_NAME")
go

CREATE INDEX "LIFECYCLE_EVENT_NODE_EVENT" ON LIFECYCLE_EVENTS("NODE_ID", "EVENT_NAME")
go

/* ----------------- node manager service types --------------------- */
create table NODE_SERVICE_TYPES(
    ID smallint NOT NULL,
    SERVICE_TYPE char(36),
    constraint "PK_NODE_SERVICE_TYPES" primary key (ID)
    )
    
go
    
/* ----------------- node manager services --------------------- */
create table NODE_SERVICES(
    ID char(36) NOT NULL,  
    NODE_ID char(36) NOT NULL,
    SERVICE_TYPE smallint NOT NULL, 
    SERVICENAME varchar(200) NOT NULL, 
    SERVICEVERSION varchar(100) NOT NULL, 
    WORKING_DIR varchar(255), 
    CAPABILITIES varchar(200) NOT NULL, 
    EXTERNALLY_MANAGED smallint NULL, 
    EXTERNALLY_STARTED smallint NULL, 
    ON_STOP_STATUS varchar(36) NOT NULL, 
    RESTART_ON_STOP varchar(36) NOT NULL,
    SERVICE_MANAGER varchar(200), 
    STARTUP_COMMAND varchar(255), 
    DEPLOYMENT_AREA char(36), 
    REPLACED_BY_ID char(36), 
    STATUS varchar(36) NOT NULL, 
    NEXT_STATUS varchar(36) NOT NULL, 
    URL varchar(200) NULL,
    BUNDLE_VERSION varchar(200),
    VERSIONHASH varchar(64),
    TECHVERSION varchar(64),
    constraint "PK_NODE_SERVICES" primary key ("ID")
    )

go
       
alter table NODE_SERVICES with check add constraint FK_NODE_ID_NODES foreign key(NODE_ID) references NODES(ID);

go

alter table NODE_SERVICES with check add constraint FK_SERVICE_TYPE_NODE_SVCS_TYPE foreign key(SERVICE_TYPE) references NODE_SERVICE_TYPES(ID);

go

alter table NODE_SERVICES add constraint FK_NODE_SERVICES_AREA_ID foreign key(DEPLOYMENT_AREA) references DEP_AREAS_DEF(AREA_ID) on delete set null
go

CREATE INDEX "NODE_SERVICES_NODE_ID" on NODE_SERVICES ("NODE_ID")

go

CREATE INDEX "NODE_SERVICES_N_ID_W_DIR_TYPE" on NODE_SERVICES ("NODE_ID","WORKING_DIR","SERVICE_TYPE")
go

CREATE INDEX "NODE_SERVICES_N_ID_W_DIR" on NODE_SERVICES ("NODE_ID","WORKING_DIR")
go

CREATE INDEX "NODE_SERVICES_N_ID_TYPE" on NODE_SERVICES ("NODE_ID","SERVICE_TYPE")
go

CREATE INDEX "NODE_SERVICES_TYPE_REPLACED" on NODE_SERVICES ("SERVICE_TYPE", "REPLACED_BY_ID")
go

create table NODE_SERVICES_PKGS (
    ID CHAR(36) NOT NULL,
    SERVICE_ID CHAR(36) NOT NULL,
    PACKAGE_ID CHAR(36) NOT NULL,
    NAME varchar(200) NOT NULL,
    VERSION varchar(32) NOT NULL,
    INTENDED_CLIENT varchar(32) NOT NULL,
    INTENDED_PLATFORM varchar(32) NOT NULL,
    LAST_MODIFIED datetime DEFAULT CURRENT_TIMESTAMP,
    constraint "PK_NODE_SERVICES_PKGS" primary key("ID")
)
go

alter table NODE_SERVICES_PKGS add constraint FK_NSPKGS_NODE_SERVICES_ID foreign key(SERVICE_ID) references NODE_SERVICES(ID) on delete cascade
go

create table SERVICE_CONFIGS (
  CONFIG_ID char(36) not null,
  CONFIG_NAME nvarchar(200) not null,
  CAPABILITY varchar(200) not null,
  PKG_ID char(36) not null,
  PKG_VERSION varchar(32) not null,
  IS_DEFAULT bit not null,
  MODIFICATION_DATE datetime not null,
  DATA varbinary(max) not null,
  CONFIG_VERSION varchar(50) not null,
  constraint PK_SERVICE_CONFIGS primary key (CONFIG_ID)
)

go

create unique index SERVICE_CONFIGS_CONFIG_NAME_IX
  on SERVICE_CONFIGS (CONFIG_NAME)

go

create table ACTIVE_SERVICE_CONFIGS (
  SERVICE_ID char(36) not null,
  CONFIG_ID char(36) not null,
  CONFIG_VERSION varchar(50) not null,
  constraint PK_ACTIVE_SERVICE_CONFIGS primary key (SERVICE_ID, CONFIG_ID),
  constraint FK_A_S_C_SERVICE_ID foreign key (SERVICE_ID)
    references NODE_SERVICES (ID) on delete cascade,
  constraint FK_A_S_C_CONFIG_ID foreign key (CONFIG_ID)
    references SERVICE_CONFIGS (CONFIG_ID) on delete cascade
)

go

create table SITE_SERVICE_CONFIGS (
  SITE_ID char(36) not null,
  CAPABILITY varchar(200) not null,
  CONFIG_ID char(36) not null,
  constraint PK_SITE_SERVICE_CONFIGS primary key (CAPABILITY),
  constraint FK_SSC_SITE_ID foreign key (SITE_ID)
    references SITES (SITE_ID) on delete cascade,
  constraint FK_SSC_CONFIG_ID foreign key (CONFIG_ID)
    references SERVICE_CONFIGS (CONFIG_ID) on delete cascade
)

go

create table NODE_AUTH_REQUEST(
   ID char(36) NOT NULL,
   CSR varbinary(1000) NOT NULL,
   LAST_MODIFIED datetime null,
   FINGERPRINT varchar(128) null,
   constraint "PK_NODE_AUTH_REQUEST" primary key("ID")
)
go

alter table NODE_AUTH_REQUEST add constraint FK_ID_NODES foreign key(ID) references NODES(ID) on delete cascade
go

create table NODE_EVENT_BUS( 
   ID char(36) NOT NULL,
   NODE_ID char(36) NOT NULL,
   COMMAND_ID char(36) NOT NULL,
   USER_ID char(36) DEFAULT NULL,
   EVENT_TYPE smallint NOT NULL,
   EVENT_SUB_TYPE char(36) NOT NULL,
   EVENT_DATA varchar(max),
   LAST_MODIFIED datetime DEFAULT CURRENT_TIMESTAMP,
   constraint "PK_NODE_EVENT_BUS" primary key("ID")
)
go

alter table NODE_EVENT_BUS add constraint FK_NODE_ID_EVENT_BUS foreign key(NODE_ID) references NODES(ID) on delete cascade
go

alter table NODE_EVENT_BUS add constraint FK_USERS_ID_EVENT_BUS foreign key(USER_ID) references USERS(USER_ID)
go

CREATE INDEX "NODE_EVENT_BUS_NODE_IDX" ON NODE_EVENT_BUS ("NODE_ID")
go

CREATE INDEX "NODE_EVENT_BUS_COMMAND_IDX" ON NODE_EVENT_BUS ("COMMAND_ID")
go

CREATE INDEX "NODE_EVENT_BUS_INDEX_CID" on NODE_EVENT_BUS ("COMMAND_ID","LAST_MODIFIED")
go

CREATE INDEX "NODE_EVENT_BUS_INDEX_NID" on NODE_EVENT_BUS ("NODE_ID","LAST_MODIFIED")
go

CREATE INDEX "NODE_EVENT_BUS_INDEX_NID_EST" on NODE_EVENT_BUS ("COMMAND_ID","EVENT_SUB_TYPE","LAST_MODIFIED")
go

CREATE INDEX "NODE_EVENT_BUS_COMMAND_TYPE" on NODE_EVENT_BUS("COMMAND_ID", "EVENT_TYPE")
go

CREATE INDEX "NODE_EVENT_BUS_N_E_STYPE" on NODE_EVENT_BUS("NODE_ID", "EVENT_SUB_TYPE")
go

create table NODE_STATUS ( 
   ID char(36) NOT NULL,
   FROM_ID char(36) NOT NULL, 
   TO_ID char(36) NOT NULL, 
   SERVICE_ID char(36) DEFAULT NULL,
   CAN_COMMUNICATE smallint default 0, 
   STATUS_CODE smallint, 
   MESSAGE varchar(1000), 
   SINCE datetime DEFAULT CURRENT_TIMESTAMP,
   LAST_MODIFIED datetime DEFAULT CURRENT_TIMESTAMP, 
   constraint "PK_NODE_STATUS" primary key("ID")
)
go

alter table NODE_STATUS add constraint FK_FROM_ID_NODE_STATUS foreign key(FROM_ID) references NODES(ID)
go

alter table NODE_STATUS add constraint FK_TO_ID_NODE_STATUS foreign key(TO_ID) references NODES(ID)
go

ALTER TABLE NODE_STATUS ADD CONSTRAINT "NODE_STATUS_ITEM" 
    UNIQUE ("FROM_ID", "TO_ID", "SERVICE_ID")
go

create trigger NODE_STATUS_NODE_FN_TR on "NODES" instead of delete 
    as
    BEGIN
    
	Delete from "NODE_STATUS"
    where "TO_ID" in 
        (SELECT d."ID" from DELETED d)
    
    Delete from "NODE_STATUS"
    where "FROM_ID" in
        (SELECT d."ID" from DELETED d)
    
    Delete from "NODE_SERVICES" 
    where "NODE_ID" in 
        (SELECT d."ID" from DELETED d)
    
    Delete NODES FROM DELETED d INNER JOIN dbo.NODES N on N.ID = d.ID
    
    END
go

create trigger NODE_STATUS_SERVICE_FN_TR on "NODE_SERVICES" instead of delete 
    as
    BEGIN
	    
    Delete from "NODE_STATUS"
    where "SERVICE_ID" in 
        (SELECT d."ID" from DELETED d)
    
    Delete NODE_SERVICES FROM DELETED d INNER JOIN dbo.NODE_SERVICES N ON N.ID = d.ID
    
    END
go

alter table NODE_STATUS add constraint FK_SERVICE_ID_NODE_STATUS foreign key(SERVICE_ID) references NODE_SERVICES(ID)
go

CREATE INDEX "NODE_STATUS_INDEX" on NODE_STATUS ("ID")
go

CREATE INDEX "NODE_STATUS_INDEX_TO_ID" on NODE_STATUS ("TO_ID")
go

CREATE INDEX "NODE_STATUS_INDEX_FROM_ID" on NODE_STATUS ("FROM_ID")
go

CREATE INDEX "NODE_STATUS_TO_SERVICE" ON NODE_STATUS("TO_ID", "SERVICE_ID")
go

CREATE INDEX "NODE_STATUS_TO_FROM" ON NODE_STATUS("TO_ID", "FROM_ID")
go

CREATE INDEX "NODE_STATUS_INDEX_SERVICE_ID" on NODE_STATUS ("SERVICE_ID")
go

CREATE INDEX "NODE_STATUS_INDEX_TO_FROM_SERVICE" on NODE_STATUS ("TO_ID","FROM_ID","SERVICE_ID")
go

create table "CERTIFICATES" (
  "SERIAL_NUMBER" varchar(40) not null,
  "NODE_ID" CHAR(36) null,
  "SUBJECT_DN" varchar(400) not null,
  "STATUS" varchar(10) not null,
  "EXPIRATION_DATE" datetime null,
  "REVOCATION_DATE" datetime null,
  "KEYSTORE" varbinary(max) null,
  constraint "CERTIFICATES_PK" primary key ("SERIAL_NUMBER"))

go
     
alter table "CERTIFICATES" with check 
  add constraint FK_CERTIFICATES_NODE_ID_NODES foreign key (NODE_ID) references NODES(ID) on delete set null;

go

CREATE INDEX "CERTIFICATES_STATUS" ON CERTIFICATES("NODE_ID","STATUS")
go


/* ------------------ OAuth2 Authorization Server ------------------ */

create table OAUTH2_CLIENTS (
  CLIENT_ID varchar(100) not null,
  JSON varbinary(max) not null,
  constraint OAUTH2_CLIENTS_PK primary key (CLIENT_ID) )

go

create table OAUTH2_AUTH_CODES (
  CODE varchar(200) not null,
  EXPIRES_AT datetime not null,
  JSON varbinary(max) not null,
  constraint OAUTH2_AUTH_CODES_PK primary key (CODE) )

go

create table OAUTH2_ACCESS_TOKENS (
  ACCESS_TOKEN varchar(200) not null,
  ACCESS_TOKEN_EXP_AT datetime not null,
  REFRESH_TOKEN varchar(200) null,
  REFRESH_TOKEN_EXP_AT datetime null,
  JSON varbinary(max) not null,
  constraint OAUTH2_ACCESS_TOKENS_PK primary key (ACCESS_TOKEN) )

go

create table OAUTH2_KEYS (
  KEY_ID varchar(200) not null,
  EXP_AT datetime not null,
  REV_AT datetime null,
  JSON varbinary(max) not null,
  constraint OAUTH2_KEYS_PK primary key (KEY_ID) )

go

/* ------------------ static routing tables ------------------ */

create table ROUTING_RULES(
	ID char(36) NOT NULL,
	NAME nvarchar(256) NOT NULL,
	ENTITY_VALUE nvarchar(max) NULL,
	ENTITY_TYPE smallint NULL,
	LIB_ITEM_ID char(36) NULL,
	GROUP_ID char(36) NULL,
	[USER_ID] char(36) NULL,
	RESOURCE_POOL_ID char(36) NULL,
	SITE_ID char(36) NULL,
	PRIORITY integer NOT NULL,
	STATUS smallint NOT NULL,	
	TYPE CHAR(1) DEFAULT('R') NOT NULL,
	LAST_MODIFIED datetime NULL,
	LAST_MODIFIED_BY char(36) NULL,
	SCHEDULING_STATUS smallint NULL,
	SCHEDULED_BY_NODE char(36) NULL,
    constraint PK_ROUTING_RULES primary key (ID),
	constraint ROUTING_RULES_UC1 unique(PRIORITY, SITE_ID),
	constraint ROUTING_RULES_UC2 unique(NAME, SITE_ID))

go

CREATE INDEX ROUTING_RULES_SITES ON ROUTING_RULES(SITE_ID)
go

create index IX_RR_RESOURCE_POOL_ID on ROUTING_RULES(RESOURCE_POOL_ID) 
go

CREATE INDEX IX_ROUTING_RULES_TYPE ON ROUTING_RULES(TYPE)
go

CREATE INDEX IX_RR_TYPE_SITE ON ROUTING_RULES(TYPE, SITE_ID)
go

CREATE INDEX IX_RR_TYPE_SITE_STATUS ON ROUTING_RULES(TYPE, SITE_ID, STATUS)
go

CREATE INDEX IX_RR_TYPE_SITE_ENTITY ON ROUTING_RULES(TYPE, SITE_ID, ENTITY_TYPE)
go

CREATE INDEX IX_ROUTING_RULES_ITEM ON ROUTING_RULES(TYPE, SITE_ID, ENTITY_TYPE, STATUS)
go


create table SERVICE_ATTRIBUTES(
	ID char(36) NOT NULL,
	ATTRIBUTE_TYPE varchar(64) NOT NULL,
	ATTRIBUTE_KEY varchar(32),
	VALUE nvarchar(256) NOT NULL,
    constraint PK_SERVICE_ATTRIBUTES primary key (ID)
	)

go

CREATE INDEX "SERVICE_ATTRIBUTES_TYPE_IDX" ON SERVICE_ATTRIBUTES ("ATTRIBUTE_TYPE")
go

CREATE INDEX "SERVICE_ATTRIBUTES_T_VAL_IDX" ON SERVICE_ATTRIBUTES ("ATTRIBUTE_TYPE", "VALUE")
go

create table NODE_SERVICES_ATTRIBUTES(
	ATTRIBUTE_ID char(36) NOT NULL,
	SERVICE_ID char(36) NOT NULL,	
    constraint PK_NODE_SERVICES_ATTRIBUTES primary key (ATTRIBUTE_ID, SERVICE_ID)	
	)

go

create table RESOURCE_POOLS(
	ID char(36) not null,
	NAME nvarchar(256) not null,
	SITE_ID char(36) not null,
	constraint PK_RESOURCE_POOLS primary key (ID),
	constraint RESOURCE_POOLS_UC1 unique (NAME, SITE_ID),
	constraint FK_RESOURCE_POOLS_SITES foreign key (SITE_ID) references SITES(SITE_ID))
go

create index RESOURCE_POOLS_SITES on RESOURCE_POOLS(SITE_ID)
go

create table NODE_SERVICES_RESOURCE_POOLS(
	SERVICE_ID char(36) not null,
	RESOURCE_POOL_ID char(36) not null,
 	constraint PK_NODES_RESOURCE_POOLS primary key (SERVICE_ID, RESOURCE_POOL_ID),
 	constraint FK_NSRP_NS foreign key (SERVICE_ID) references NODE_SERVICES (ID) on delete cascade,
 	constraint FK_NSRP_RP foreign key (RESOURCE_POOL_ID) references RESOURCE_POOLS (ID) on delete cascade)
go

create index IX_NSRP_SERVICE_ID on NODE_SERVICES_RESOURCE_POOLS(SERVICE_ID) 
go

create index IX_NSRP_RESOURCE_POOL_ID on NODE_SERVICES_RESOURCE_POOLS(RESOURCE_POOL_ID) 
go

alter table ROUTING_RULES  add constraint FK_ROUT_RULES_LIB_ITEMS foreign key(LIB_ITEM_ID)references LIB_ITEMS(ITEM_ID)
on delete set null
go

alter table ROUTING_RULES  add constraint FK_ROUT_RULES_GROUPS foreign key(GROUP_ID)references GROUPS(GROUP_ID)
on delete set null
go

alter table ROUTING_RULES  add constraint FK_ROUT_RULES_USERS foreign key([USER_ID])references USERS([USER_ID])
on delete set null
go

alter table ROUTING_RULES add constraint FK_ROUT_RULES_RES_POOLS foreign key(RESOURCE_POOL_ID)references RESOURCE_POOLS(ID)
go

ALTER TABLE ROUTING_RULES WITH CHECK ADD CONSTRAINT FK_ROUTING_RULES_SITE_ID FOREIGN KEY (SITE_ID) REFERENCES SITES (SITE_ID);
GO

ALTER TABLE ROUTING_RULES CHECK CONSTRAINT FK_ROUTING_RULES_SITE_ID;
GO

alter table ROUTING_RULES add constraint ROUTING_RULES_STATUS check (			
	(STATUS = 0) 
	or 
	(STATUS = 1)	
	or 
    (STATUS = 2)
    or 
    (STATUS = 3)
)

go

alter table ROUTING_RULES add constraint ROUTING_RULES_TYPES check (			
	([TYPE] = 'R') 
	or 
	([TYPE] = 'D')	
);

alter table NODE_SERVICES_ATTRIBUTES  add constraint FK_NSA_SA foreign key(ATTRIBUTE_ID)references SERVICE_ATTRIBUTES (ID)
on delete cascade

go

alter table NODE_SERVICES_ATTRIBUTES  add constraint FK_NSA_NS foreign key(SERVICE_ID)references NODE_SERVICES (ID)
on delete cascade

go

create procedure routingRules_updatePriority ( 
   @ruleId char(36),
   @newPriority integer) as
begin
   set nocount on
   
   declare @direction char(4)
   declare @siteId char(36)
 
   SELECT @direction = CASE WHEN @newPriority > PRIORITY THEN 'DOWN' ELSE 'UP' END FROM ROUTING_RULES WHERE ID = @ruleId
 
   SELECT @siteId = SITE_ID FROM ROUTING_RULES WHERE ID = @ruleId

   /* First in priority are regular rules, then default rules, then deleted rules */
   
   UPDATE ROUTING_RULES
   SET PRIORITY = U.NEW_PRIORITY  - 1
   FROM ROUTING_RULES 
   INNER JOIN SITES S ON ROUTING_RULES.SITE_ID = S.SITE_ID
   INNER JOIN
   (SELECT ID, NAME, ROW_NUMBER() OVER(ORDER BY  
                                   CASE WHEN TYPE = 'R' THEN   
                                       CASE WHEN STATUS <> 2 THEN 'A'
                                       ELSE 'B' END
                                   ELSE 'C' END,
                                   CASE WHEN ID = @ruleId THEN @newPriority   
                                   WHEN PRIORITY < @newPriority THEN PRIORITY - 1
                                   WHEN PRIORITY = @newPriority AND @direction = 'DOWN' THEN PRIORITY - 1
                                   WHEN PRIORITY = @newPriority AND @direction = 'UP' THEN PRIORITY + 1
                                   WHEN PRIORITY >= @newPriority THEN PRIORITY + 1 END ASC) AS NEW_PRIORITY 
                                   FROM ROUTING_RULES
                                   WHERE ROUTING_RULES.SITE_ID = @siteId
                                   ) U ON ROUTING_RULES.ID = U.ID
   WHERE ROUTING_RULES.SITE_ID = @siteId
 
end;
GO
 
create procedure routingRules_deleteRule ( 
   @ruleId char(36)) as
begin
   set nocount on     
   
   declare @siteId char(36)
 
   SELECT @siteId = SITE_ID FROM ROUTING_RULES WHERE ID = @ruleId
 
   -- delete
   delete from ROUTING_RULES where ID = @ruleId    
       
   -- update priority
   UPDATE ROUTING_RULES
   SET PRIORITY = U.NEW_PRIORITY  - 1
   FROM ROUTING_RULES    
   INNER JOIN
   (SELECT ID, NAME, ROW_NUMBER() OVER(ORDER BY
       CASE WHEN TYPE = 'R' THEN   
           CASE WHEN STATUS <> 2 THEN 'A'
           ELSE 'B' END
       ELSE 'C' END,
       PRIORITY) AS NEW_PRIORITY FROM ROUTING_RULES
       WHERE ROUTING_RULES.SITE_ID = @siteId) U
   ON ROUTING_RULES.ID = U.ID
   WHERE ROUTING_RULES.SITE_ID = @siteId
       
end;
GO

create procedure usp_findRoutingRules
	@user_id char(36),
	@lib_item_id char(36),
	@site_id char(36)
as
begin
	set nocount on;
	if @user_id is null or @site_id is null 
		raiserror('ERR-50004 - Illegal argument. %s', 16, 1, 'Required arguments are not defined.'); 
	 WITH ALL_USER_GROUPS (GROUP_ID) AS  
	 ( 
	 select gm.GROUP_ID from GROUP_MEMBERS_VIEW gm
      where gm.MEMBER_USER_ID = COALESCE(@user_id,'')
     union all
     select gm.GROUP_ID from GROUP_MEMBERS_VIEW gm, ALL_USER_GROUPS cte
       where cte.GROUP_ID = gm.MEMBER_GROUP_ID
	 ),
	ALL_PARENTS (ITEM_ID) as (
	SELECT PARENT_ID FROM LIB_ITEMS
	WHERE ITEM_ID = COALESCE(@lib_item_id,'')
	UNION ALL
	SELECT items.PARENT_ID
	 FROM LIB_ITEMS items, ALL_PARENTS cte 
	 WHERE items.ITEM_ID = cte.ITEM_ID
)
SELECT rules.ID
      ,rules.NAME
      ,rules.LIB_ITEM_ID
      ,rules.GROUP_ID
      ,rules.USER_ID
      ,rules.RESOURCE_POOL_ID
      ,rules.PRIORITY
      ,rules.STATUS
      ,rules.TYPE
FROM ROUTING_RULES rules
LEFT JOIN ALL_PARENTS parents ON rules.LIB_ITEM_ID = parents.ITEM_ID
LEFT JOIN ALL_USER_GROUPS groups ON rules.GROUP_ID = groups.GROUP_ID
WHERE rules.[STATUS] = 1 
AND rules.SITE_ID = @site_id
AND((COALESCE(rules.LIB_ITEM_ID,'') <> '' AND rules.LIB_ITEM_ID = COALESCE(@lib_item_id,'')) --direct match
	OR (COALESCE(rules.LIB_ITEM_ID,'') <> '' and COALESCE(parents.ITEM_ID,'') <> '') --parent folder match
	OR (COALESCE(rules.GROUP_ID, '') <> '' and COALESCE(groups.GROUP_ID, '') <> '') --group match
	OR (COALESCE(rules.USER_ID, '') = @user_id) --user match
	OR rules.[TYPE] = 'D' --default rules
) 
ORDER BY rules.PRIORITY asc
END;
go

/* ----------------- scheduler schema --------------------- */
create table JOB_SCHEDULES(
    ID char(36) NOT NULL,
    NAME nvarchar(32) NULL,	
    START_TIME bigint NULL,
    END_TIME bigint NULL,
    WEEK_DAYS nvarchar(200) NULL,	
    LAST_MODIFIED datetime NULL,
    LAST_MODIFIED_BY char(36) NULL,	
    IS_JOB_SPECIFIC smallint NULL,
    RELOAD_FREQUENCY smallint NULL,
    RELOAD_UNIT nvarchar(16) NULL,
    TIMEZONE varchar(64) NULL,	
    SITE_ID char(36) NULL,
    constraint "PK_JOB_SCHEDULES" primary key ("ID"),
    constraint FK_JOB_SCHEDULES_SITE_ID foreign key (SITE_ID) references SITES(SITE_ID)
)

go

CREATE INDEX JOB_SCHEDULES_SITES ON JOB_SCHEDULES(SITE_ID)

go

CREATE TABLE SCHEDULED_UPDATES_SETTINGS(
	ROUTING_RULE_ID char(36) NOT NULL,
	INSTANCES_COUNT smallint NULL,
	CLIENT_UPDATE_MODE varchar(32) NULL,
	ALLOW_CACHED_DATA smallint NULL,
	PRECOMPUTE_RELATIONS smallint NULL,
	PRECOMPUTE_VISUALIZATIONS smallint NULL,
	PRECOMPUTE_ACTIVE_PAGE smallint NULL,
 CONSTRAINT PK_SCHEDULED_UPDATES_SETTINGS PRIMARY KEY(ROUTING_RULE_ID))

 go
 
 CREATE TABLE RULES_SCHEDULES(
 	ROUTING_RULE_ID char(36) NOT NULL,
	SCHEDULE_ID char(36) NOT NULL,
CONSTRAINT PK_RULES_SCHEDULES PRIMARY KEY(ROUTING_RULE_ID, SCHEDULE_ID))

go
 
create table JOB_INSTANCES(
	INSTANCE_ID char(36) NOT NULL,
	TYPE char(1) NOT NULL DEFAULT 'S',
	STATUS smallint NULL,
	CREATED datetime NULL,
	LAST_MODIFIED datetime NULL,
	ROUTING_RULE_ID char(36) NULL,
	SCHEDULE_ID char(36) NULL,
	SITE_ID char(36) NULL,
	JOB_CONTENT nvarchar(MAX),
	ERROR_MESSAGE nvarchar(1024) NULL,
	EXECUTION_TYPE smallint NULL,
	constraint "PK_JOB_INSTANCES" primary key ("INSTANCE_ID"))
 
go

ALTER TABLE JOB_INSTANCES  ADD  CONSTRAINT [JOB_INSTANCES_TYPES] CHECK  (([TYPE]='S' OR [TYPE]='A'))
go

ALTER table JOB_INSTANCES WITH CHECK add constraint FK_JOB_INSTANCES_SCHEDULES foreign key(SCHEDULE_ID)references JOB_SCHEDULES (ID)
go

ALTER table JOB_INSTANCES CHECK CONSTRAINT FK_JOB_INSTANCES_SCHEDULES
go

ALTER TABLE JOB_INSTANCES WITH CHECK ADD CONSTRAINT FK_JOB_INSTANCES_SITE_ID FOREIGN KEY (SITE_ID) REFERENCES SITES (SITE_ID)
go

ALTER table JOB_INSTANCES CHECK CONSTRAINT FK_JOB_INSTANCES_SITE_ID
go

CREATE INDEX JOB_INSTANCES_STATUS_IDX
ON JOB_INSTANCES (STATUS)

GO

CREATE INDEX JOB_INSTANCES_RULE_IDX
ON JOB_INSTANCES (ROUTING_RULE_ID)

GO

CREATE INDEX JOB_INSTANCES_TYPE_STATUS_IDX 
ON JOB_INSTANCES (TYPE, EXECUTION_TYPE, STATUS)
 
GO

CREATE INDEX "JOB_INSTANCES_TYPE_IDX" ON JOB_INSTANCES ("TYPE")
go

CREATE INDEX "JOB_INSTANCES_TYPE_STAT_IDX" ON JOB_INSTANCES ("TYPE", "STATUS")
go

CREATE INDEX JOB_INSTANCES_SITES ON JOB_INSTANCES(SITE_ID)

go

create table JOB_TASKS(
	TASK_ID char(36) NOT NULL,	
	JOB_ID char(36) NOT NULL,
	STATUS smallint NULL,
	MESSAGE nvarchar(1024) NULL,
	TASK_EXTERNAL_ID nvarchar(36) NULL,
	SERVICE_ID char(36) NULL,
	DESTINATION nvarchar(512) NULL,
	CREATED datetime NULL,
	LAST_MODIFIED datetime NULL,
    constraint "PK_JOB_TASKS" primary key ("TASK_ID"))
 
go

CREATE INDEX JOB_TASKS_JOB_ID_IDX
ON JOB_TASKS (JOB_ID)  

GO

ALTER TABLE SCHEDULED_UPDATES_SETTINGS  WITH CHECK ADD  CONSTRAINT FK_SUS_RR FOREIGN KEY(ROUTING_RULE_ID)
REFERENCES ROUTING_RULES (ID) on delete cascade

go

ALTER TABLE SCHEDULED_UPDATES_SETTINGS CHECK CONSTRAINT FK_SUS_RR

go

ALTER TABLE RULES_SCHEDULES  WITH CHECK ADD  CONSTRAINT FK_RS_RR FOREIGN KEY(ROUTING_RULE_ID)
REFERENCES ROUTING_RULES (ID) on delete cascade

GO

ALTER TABLE RULES_SCHEDULES  WITH CHECK ADD  CONSTRAINT FK_RS_JS FOREIGN KEY(SCHEDULE_ID)
REFERENCES JOB_SCHEDULES (ID) on delete cascade

GO

ALTER TABLE JOB_INSTANCES  WITH CHECK ADD  CONSTRAINT FK_JOBS_ROUTING_RULES FOREIGN KEY(ROUTING_RULE_ID) REFERENCES ROUTING_RULES (ID) ON DELETE SET NULL

go  

ALTER TABLE JOB_INSTANCES CHECK CONSTRAINT FK_JOBS_ROUTING_RULES

go

ALTER TABLE JOB_TASKS  WITH CHECK ADD  CONSTRAINT FK_JOB_TASKS_JOBS FOREIGN KEY(JOB_ID)
REFERENCES JOB_INSTANCES (INSTANCE_ID) ON DELETE CASCADE

go

ALTER TABLE JOB_TASKS CHECK CONSTRAINT FK_JOB_TASKS_JOBS

go
create view JOB_INSTANCES_DETAIL_VIEW
AS SELECT JOB.INSTANCE_ID
      ,JOB.TYPE	
      ,JOB.STATUS
      ,JOB.CREATED
      ,JOB.LAST_MODIFIED
      ,JOB.ROUTING_RULE_ID
      ,JOB.JOB_CONTENT		
      ,JOB.ERROR_MESSAGE
      ,JOB.EXECUTION_TYPE
      ,JOB.SITE_ID
      ,ROUTING_RULES.NAME,
COALESCE(U.TOTAL_TASKS_COUNT,0) TOTAL_TASKS_COUNT, 
COALESCE(U.COMPLETED_TASKS_COUNT,0) COMPLETED_TASKS_COUNT,
COALESCE(U.FAILED_TASKS_COUNT,0) FAILED_TASKS_COUNT,
COALESCE(U.IN_PROGRESS_TASKS_COUNT,0) IN_PROGRESS_TASKS_COUNT
FROM JOB_INSTANCES JOB
LEFT JOIN ROUTING_RULES ON JOB.ROUTING_RULE_ID = ROUTING_RULES.ID
LEFT JOIN ( 
select JOB_ID, COUNT(*) AS TOTAL_TASKS_COUNT,
SUM(case when STATUS = 5 THEN 1 ELSE 0 END) AS COMPLETED_TASKS_COUNT,
SUM(case when STATUS = 3 THEN 1 ELSE 0 END) AS FAILED_TASKS_COUNT,
SUM(case when STATUS = 1 THEN 1 ELSE 0 END) AS IN_PROGRESS_TASKS_COUNT
FROM JOB_TASKS
GROUP BY JOB_ID
) U ON JOB.INSTANCE_ID = U.JOB_ID

go

CREATE VIEW RESOURCE_POOLS_SERVICES_VIEW AS 
WITH A AS (
 SELECT NSRP.SERVICE_ID, RP.ID AS RESOURCE_POOL_ID, RP.NAME AS RESOURCE_POOL_NAME
        FROM NODE_SERVICES_RESOURCE_POOLS NSRP
        INNER JOIN RESOURCE_POOLS RP ON NSRP.RESOURCE_POOL_ID = RP.ID        
),
B AS (
    SELECT NS.ID, NS.SERVICE_TYPE, NS.NODE_ID, NS.WORKING_DIR, NS.URL, NS.CAPABILITIES,
    A.RESOURCE_POOL_ID, A.RESOURCE_POOL_NAME, NS.DEPLOYMENT_AREA, NS.STATUS
    FROM NODE_SERVICES NS
    LEFT JOIN A ON NS.ID = A.SERVICE_ID
    WHERE NS.CAPABILITIES LIKE '%WEB_PLAYER%'
)
SELECT B.ID, B.SERVICE_TYPE, B.NODE_ID, B.WORKING_DIR, B.URL, B.CAPABILITIES,
    B.RESOURCE_POOL_ID, B.RESOURCE_POOL_NAME, B.DEPLOYMENT_AREA, B.STATUS,
    DAD.DEP_AREA_NAME, NSI.SERVERNAME, N.SITE_ID
FROM B
LEFT JOIN DEP_AREAS_DEF DAD ON B.DEPLOYMENT_AREA = DAD.AREA_ID
INNER JOIN NODES N ON B.NODE_ID = N.ID
INNER JOIN NODE_SERVER_INFO NSI ON NSI.NODE_ID = N.ID AND NSI.PRIORITY = 1
go

/* ----------------- Persistent Sessions ("remember me") --------------------- */

create table PERSISTENT_SESSIONS (
  SESSION_ID varchar(100) not null,
  USER_ID char(36) not null,
  TOKEN_HASH varchar(150) not null,
  VALID_UNTIL datetime not null,
  constraint PERSISTENT_SESSIONS_PK primary key (SESSION_ID),
  constraint FK_USERS_USER_ID foreign key (USER_ID) references USERS (USER_ID) on delete cascade )

go

/* ----------------- Invitations  --------------------- */
create table INVITES (
  SENDER_ID char(36) not null,
  ITEM_ID char(36) not null,
  INVITE_TOKEN varchar(200) not null,
  CREATED datetime not null,
  EMAIL varchar(255) not null,
  constraint PK_INVITES primary key (SENDER_ID, ITEM_ID, EMAIL),
  constraint FK_INVITES_USERS foreign key (SENDER_ID) references USERS (USER_ID) on delete cascade, 
  constraint FK_INVITES_LIB_ITEMS foreign key (ITEM_ID) references LIB_ITEMS (ITEM_ID) on delete cascade)
go

/* ----------------- Additional indices on FK  constraints --------------------- */
create index "INVITES_ITEM_ID_IDX" on "INVITES" ("ITEM_ID")
go
create index "IX_ACTIVE_SERVICE_CONFIGS_CONFIG_ID" on "ACTIVE_SERVICE_CONFIGS" ("CONFIG_ID") 
go
create index "IX_CUSTOMIZED_LICENSES_GROUP_ID" on "CUSTOMIZED_LICENSES" ("GROUP_ID") 
go
create index "IX_CUSTOMIZED_LICENSES_LICENSE_NAME" on "CUSTOMIZED_LICENSES" ("LICENSE_NAME") 
go
create index "IX_DEP_AREAS_DISTRIBUTION_ID" on "DEP_AREAS" ("DISTRIBUTION_ID") 
go
create index "IX_DEP_DISTRIBUTION_CONTENTS_DISTRIBUTION_ID" on "DEP_DISTRIBUTION_CONTENTS" ("DISTRIBUTION_ID") 
go
create index "IX_EXCLUDED_FUNCTIONS_LICENSE_FUNCTION_ID" on "EXCLUDED_FUNCTIONS" ("LICENSE_FUNCTION_ID") 
go
create index "IX_JOB_INSTANCES_SCHEDULE_ID" on "JOB_INSTANCES" ("SCHEDULE_ID") 
go
create index "IX_LIB_DATA_CHARACTER_ENCODING" on "LIB_DATA" ("CHARACTER_ENCODING") 
go
create index "IX_LIB_DATA_CONTENT_TYPE" on "LIB_DATA" ("CONTENT_TYPE") 
go
create index "IX_LIB_DATA_CONTENT_ENCODING" on "LIB_DATA" ("CONTENT_ENCODING") 
go
create index "IX_LIB_VISIBLE_TYPES_APPLICATION_ID" on "LIB_VISIBLE_TYPES" ("APPLICATION_ID") 
go
create index "IX_LICENSE_FUNCTIONS_LICENSE_NAME" on "LICENSE_FUNCTIONS" ("LICENSE_NAME") 
go
create index "IX_LICENSE_ORIGIN_PACKAGE_ID" on "LICENSE_ORIGIN" ("PACKAGE_ID") 
go
create index "IX_LICENSE_ORIGIN_LICENSE_FUNCTION_ID" on "LICENSE_ORIGIN" ("LICENSE_FUNCTION_ID") 
go
create index "IX_NODE_EVENT_BUS_USER_ID" on "NODE_EVENT_BUS" ("USER_ID") 
go
create index "IX_NODE_SERVICES_DEPLOYMENT_AREA" on "NODE_SERVICES" ("DEPLOYMENT_AREA") 
go
create index "IX_NODE_SERVICES_ATTRIBUTES_SERVICE_ID" on "NODE_SERVICES_ATTRIBUTES" ("SERVICE_ID") 
go
create index "IX_NODE_SERVICES_PKGS_SERVICE_ID" on "NODE_SERVICES_PKGS" ("SERVICE_ID") 
go
create index "IX_NODES_DEPLOYMENT_AREA" on "NODES" ("DEPLOYMENT_AREA") 
go
create index "IX_PERSISTENT_SESSIONS_USER_ID" on "PERSISTENT_SESSIONS" ("USER_ID") 
go
create index "IX_PREFERENCE_OBJECTS_GROUP_ID" on "PREFERENCE_OBJECTS" ("GROUP_ID") 
go
create index "IX_PREFERENCE_OBJECTS_USER_ID" on "PREFERENCE_OBJECTS" ("USER_ID") 
go
create index "IX_PREFERENCE_VALUES_PREFERENCE_ID" on "PREFERENCE_VALUES" ("PREFERENCE_ID") 
go
create index "IX_PREFERENCE_VALUES_USER_ID" on "PREFERENCE_VALUES" ("USER_ID") 
go
create index "IX_ROUTING_RULES_GROUP_ID" on "ROUTING_RULES" ("GROUP_ID") 
go
create index "IX_ROUTING_RULES_LIB_ITEM_ID" on "ROUTING_RULES" ("LIB_ITEM_ID") 
go
create index "IX_ROUTING_RULES_USER_ID" on "ROUTING_RULES" ("USER_ID") 
go
create index "IX_RULES_SCHEDULES_SCHEDULE_ID" on "RULES_SCHEDULES" ("SCHEDULE_ID") 
go
create index "IX_SITE_SERVICE_CONFIGS_CONFIG_ID" on "SITE_SERVICE_CONFIGS" ("CONFIG_ID") 
go
create index "IX_SITE_SERVICE_CONFIGS_SITE_ID" on "SITE_SERVICE_CONFIGS" ("SITE_ID") 
go

