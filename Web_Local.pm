package HTML::Mason::Commands;
# Let tables through
push @SCRUBBER_ALLOWED_TAGS, qw(TABLE THEAD TBODY TFOOT TR TD TH);
1;
