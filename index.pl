#!/usr/bin/perl

use strict;
use warnings;

use File::Copy;
use Carp;

sub gallery() {
    my ( $cam, $day, $hr, $min, $ext );
    if ( $ARGV[0] =~
/^([^_]+)_([\d]{4}-[\d]{2}-[\d]{2})_([\d]{2})_([\d]{2})(_[\d]{2})?\.([\w]+)$/
      )
    {
        ( $cam, $day, $hr, $min, undef, $ext ) = ( $1, $2, $3, $4, $5, $6 );
    }
    else {
        # Currently, don't handle different inputs.
        exit;
    }

    print "$cam on $day at $hr:$min type $ext\n";

    mkdir 'gallery' || carp "Can't make gallery directory: $@";

    my $hour_part = "${cam}_${day}_${hr}";
    my $mask      = "${hour_part}_*.${ext}";

    mkdir $day || carp "Can't make image sub-directory $day: $@";
    foreach ( glob $mask ) {
        move( $_, $day ) || carp "Can't move images $mask into $day: $@";
    }

    # exit;

# Actually source path could be $day/*, but let's allow other types of files being stored there.
    my $gallery = "gallery/${hour_part}";
    my $gallery_cmd =
"montage -define jpeg:size=256x256 ${day}/${mask} -tile x1 -geometry x128+1+1 ${gallery}.html";
    print "Running: $gallery_cmd\n";
    system($gallery_cmd) && carp "Can't create gallery page: $@";
    system("convert ${gallery}.png ${gallery}.jpg")
      && carp "Can't convert ${gallery}.png to ${gallery}.jpg: $@";
    unlink("${gallery}.png") || carp "Couldn't delete ${gallery}.png: $@";
    unlink("${hour_part}_map.shtml")
      || carp "Couldn't delete ${hour_part}.shtml: $@";

    exit;

    open( my $idx, '>', 'index.html.tmp' )
      || carp "Couldn't write index.html.tmp: $@";
    print( $idx
'<!DOCTYPE html><html><head><style>ul { font-size: large; line-height: 200%; }</style></head>'
    );
    print( $idx
'<body><p>All times are in HST Hawai\'i Standard Time (UTC -10:00), no DST.</p><ul>'
    );
    opendir( my $dir, '.' ) || carp "Couldn't open current directory: $@";
    my @dirs = reverse sort readdir $dir;

    foreach my $date (@dirs) {
        next if ( '.' eq $date );
        next if ( '..' eq $date );
        next if ( 'HST' eq $date );
        next if ( 'tmp' eq $date );
        next if ( 'bad' eq $date );
        next if ( 'dark' eq $date );
        next if ( 'dark2' eq $date );
        next if ( 'gallery' eq $date );
        next if ( !-d $date );
        system(
"bash -c 'egrep -h \"(title|img|map|area)\" gallery/${cam}_${date}_*.html | sed -r \"s/\.png/\.jpg/;s/<title>[^_]*_[^_]*_(.*)<\\/title>/<br \\/><div>\\1:00<\\/div>/\" > ${cam}_${date}.html'"
        );
        print( $idx "<li><a href=\"${cam}_${date}.html\">${date}</a></li>" );
    }
    print( $idx '</ul></body></html>' );
    close($idx) || carp "Couldn't close index.html.tmp: $@";
    move( 'index.html.tmp', 'index.html' )
      || carp "Couldn't move index.html.tmp into index.html: $@";
}

$ENV{PATH} = "/usr/local/bin:/bin";

gallery();
