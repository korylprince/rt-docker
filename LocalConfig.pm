# basics
Set($rtname, $ENV{'RT_NAME'});
Set($Organization, $ENV{'RT_ORGANIZATION'});

# webserver
Set($WebDomain, $ENV{'RT_WEB_DOMAIN'});
Set($WebPort, $ENV{'RT_WEB_PORT'});
Set($WebPath, $ENV{'RT_WEB_PATH'});
Set($WebBaseURL , $ENV{'RT_WEB_BASE_URL'});
Set($CanonicalizeRedirectURLs, 1);

# email
Set($CorrespondAddress , $ENV{'RT_CORRESPOND_ADDRESS'});
Set($CommentAddress , $ENV{'RT_COMMENT_ADDRESS'});

# create email regexp
my $emails = $ENV{'RT_ADDRESSES'};
$emails =~ s/@/\\@/g;
$emails =~ s/\./\\./g;
$emails =~ s/,/|/g;
Set($RTAddressRegexp , "^($emails)\$");

# database
Set($DatabaseType, 'mysql');
Set($DatabaseHost, $ENV{'RT_DB_HOST'});
Set($DatabasePort, $ENV{'RT_DB_PORT'});
Set($DatabaseUser , $ENV{'RT_DB_USER'});
Set($DatabasePassword , $ENV{'RT_DB_PASS'});
Set($DatabaseName , $ENV{'RT_DB_NAME'});

# LDAP authentication
Set($ExternalSettings, {
        'My_LDAP' => {
            'type' => 'ldap',
            'server' => $ENV{'RT_LDAP_HOST'},
            'user' => $ENV{'RT_LDAP_USER'},
            'pass' => $ENV{'RT_LDAP_PASS'},
            'base' => $ENV{'RT_LDAP_BASE_DN'},
            'filter' => '(objectClass=*)',
            'd_filter' => '(userAccountControl:1.2.840.113556.1.4.803:=2)',
            'tls' => {
                verify => 'require',
                capath => '/etc/ssl/certs/'
            },
            'net_ldap_args' => [version => 3],
            'group' => $ENV{'RT_LDAP_GROUP'},
            'group_attr' => 'member',
            'attr_match_list' => ['Name','EmailAddress'],
            'attr_map' => {
                'Name' => 'sAMAccountName',
                'EmailAddress' => 'mail',
                'Organization' => 'physicalDeliveryOfficeName',
                'RealName' => 'displayName',
                'Gecos' => 'sAMAccountName',
                'WorkPhone' => 'telephoneNumber',
                'Address1' => 'streetAddress',
                'City' => 'l',
                'State' => 'st',
                'Zip' => 'postalCode',
                'Country' => 'co'
            }
        }
    });
Set($ExternalAuthPriority, ['My_LDAP']);
Set($ExternalInfoPriority, ['My_LDAP']);
Set($AutoCreateNonExternalUsers, 1);

# set timezone
Set($Timezone, $ENV{'RT_TIMEZONE'});
Set($ChartsTimezonesInDB, 1);

# logging
Set($LogToSyslog, undef);
Set($LogToFile, undef);
Set($LogToScreen, $ENV{'RT_LOG_LEVEL'});

# enable charts
Set($DisableGD, 0);

# enable full text search
Set(%FullTextSearch,
    Enable => 1,
    Indexed => 1,
    Table => 'AttachmentsIndex'
);

# set Shredder path
Set($ShredderStoragePath, "/shredder");
