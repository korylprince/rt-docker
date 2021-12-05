# database
Set($DatabaseType, 'mysql');
Set($DatabaseHost, $ENV{'RT_DB_HOST'});
Set($DatabasePort, $ENV{'RT_DB_PORT'});
Set($DatabaseUser , $ENV{'RT_DB_USER'});
Set($DatabasePassword , $ENV{'RT_DB_PASS'});
Set($DatabaseName , $ENV{'RT_DB_NAME'});

# set timezone
Set($Timezone, $ENV{'RT_TIMEZONE'});
Set($ChartsTimezonesInDB, 1);

# logging
Set($LogToSyslog, undef);
Set($LogToFile, undef);
Set($LogToScreen, $ENV{'RT_LOG_LEVEL'});

# enable full text search
Set(%FullTextSearch,
    Enable => 1,
    Indexed => 1,
    Table => 'AttachmentsIndex'
);
