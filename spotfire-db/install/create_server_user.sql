/*
 * Copyright (c) 2008-2012 Spotfire AB,
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

/* spotfire_server */
use master
go

CREATE LOGIN  $(SERVERDB_USER) WITH PASSWORD=N'$(SERVERDB_PASSWORD)', DEFAULT_DATABASE=[$(SERVERDB_NAME)], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

ALTER LOGIN  $(SERVERDB_USER) ENABLE
GO

DENY VIEW ANY DATABASE
TO  $(SERVERDB_USER)

use [$(SERVERDB_NAME)]
GO

CREATE USER  $(SERVERDB_USER)

GRANT CONTROL TO  $(SERVERDB_USER)
GO
