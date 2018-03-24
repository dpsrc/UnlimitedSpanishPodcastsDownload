#! /usr/bin/perl -w

# Downloads the podcast episodes from https://www.unlimitedspanish.com/podcasts/ -
# the excellent Spanish learning resource.
# It parses each episode page and obtains the URLs of .mp3 and .pdf files
# as well as the episode name.
# Then it downloads these files and renames them to the episode name.
# Different formats of URLs and names for different episode diapasons
# as well as known special cases (typos and not only those) for some episodes
# are taken into account.
# TODO: remove debug information and make it possible to take episode numbers and diapasons from the command line and check if there are known special cases for episodes after 80.

my $iform; # Formatted episode number, e.g., 4 -> 004, 12 -> 012, 104 -> 104
my $urlpage; # Web page URL with an eposide
my $urlmp3; # The URL of the .MP3 file for an eposide
my $urlpdf; # The URL of the .PDF file for an eposide
my $tmpfilemp3name; # The tmp name to download the .MP3 file as
my $tmpfilepdfname; # The tmp name to download the .PDF file as
my $finalname; # The final name (without extension) to rename the .MP3 and the .PDF files to
my $success;

for (my $i=1; $i <= 200; $i++) {
#   my $input = <STDIN>;

   $iform = $urlpage = $urlmp3 = $urlpdf = $tmpfilemp3name = $tmpfilepdfname = $finalname = "";

   $iform = sprintf("%03d", $i);
   system("rm -f ${iform}.html wget.log > /dev/null");
   print "\n\n======================== $i $iform \n\n";

#   if ($i <= 60 || $i == 73) {
      $urlpage = "http://www.unlimitedspanish.com/${iform}/";
      $success = 1;

      if ($i == 7) {
         $urlpage = "http://www.unlimitedspanish.com/las-tapas-concentracion-al-escuchar/";
      }

      if ($i == 16) {
         $urlpage = "http://www.unlimitedspanish.com/los-canales-de-tv-cuando-parar-de-estudiar-espanol/";
      }

      if ($i == 28) {
         $urlpage = "http://www.unlimitedspanish.com/usp-029-en-el-pasado-fluidez-vs-perfeccion/";
      }

      if ($i == 29) { # Because http://www.unlimitedspanish.com/usp-029/ gets redirected to the 28th episode
         $urlpage = "http://www.unlimitedspanish.com/usp-029-tiempo-en-espana-adapta-tu-espanol-a-tu-vida/";
      }

      if ($i == 34) { # Simply http://www.unlimitedspanish.com/34/ does not work
         $urlpage = "http://www.unlimitedspanish.com/34-los-sanfermines/";
      }

      # There is no PDF file for the episode 36

      if ($i == 61) {
         $urlpage = "http://www.unlimitedspanish.com/p60parentescoii/";
      }

      if ($i == 73) {
         $urlpage = "http://www.unlimitedspanish.com/espanol-coloquial-trabajo/";
      }

      print("Trying $urlpage\n");
      if (system("wget -nc $urlpage -o wget.log -O ${iform}.html")) {
         system("rm -f ${iform}.html wget.log > /dev/null");
         $urlpage = "http://www.unlimitedspanish.com/usp-$iform/";
         print("Trying $urlpage\n");
         if (system("wget -nc $urlpage -o wget.log -O ${iform}.html")) {
            system("rm -f ${iform}.html wget.log > /dev/null");
            $urlpage = "http://www.unlimitedspanish.com/usp$iform/";
            print("Trying $urlpage\n");
            if (system("wget -nc $urlpage -o wget.log -O ${iform}.html")) {
               system("rm -f ${iform}.html wget.log > /dev/null");
               $urlpage = "http://www.unlimitedspanish.com/usp-$i/";
               print("Trying $urlpage\n");
               if (system("wget -nc $urlpage -o wget.log -O ${iform}.html")) {
                  system("rm -f ${iform}.html wget.log > /dev/null");
                  $urlpage = "http://www.unlimitedspanish.com/usp$i/";
                  print("Trying $urlpage\n");
                  if (system("wget -nc $urlpage -o wget.log -O ${iform}.html")) {
                     system("rm -f ${iform}.html wget.log > /dev/null");
                     $urlpage = "http://www.unlimitedspanish.com/ups${iform}/";
                     print("Trying $urlpage\n");
                     if (system("wget -nc $urlpage -o wget.log -O ${iform}.html")) {
                        system("rm -f ${iform}.html wget.log > /dev/null");
                        $urlpage = "http://www.unlimitedspanish.com/ups-${iform}/";
                        print("Trying $urlpage\n");
                        if (system("wget -nc $urlpage -o wget.log -O ${iform}.html")) {
                           $success = 0;
                        }
                     }
                  }
               }
            }
         }
      }
      if ($success == 0) {
         print("Unable to wget the HTML page for the episode $i\n");
         next;
      }

   print("============== urlpage = $urlpage\n\n");

   # Obtaining the .MP3 file URL to download
   $urlmp3 = `grep -o -m 1 -P '(http[s]*:[\\d\\w\\W\\/\\.\\-]+\\.mp3)' ${iform}.html`;
   $urlmp3 = (split('\n', $urlmp3))[0]; # Getting rid of trailing EOL
   print("urlmp3 = [$urlmp3]\n");
   $tmpfilemp3name = "${iform}.mp3";
   print("tmpfilemp3name = [$tmpfilemp3name]\n");

   # Obtaining the .PDF file URL to download
   $urlpdf = `grep -o -m 1 -P '(http[s]*:[\\d\\w\\W\\/\\.\\-]+\\.pdf)' ${iform}.html`;
   $urlpdf = (split('\n', $urlpdf))[0]; # Getting rid of trailing EOL
   print("urlpdf = [$urlpdf]\n");
   $tmpfilepdfname = "${iform}.pdf";
   print("tmpfilepdfname = [$tmpfilepdfname]\n");

   $finalname = `grep 'Location\:' wget.log | awk -F '/' '{print \$(NF-1)}'`;
   if ($finalname eq "") {
      $finalname = `grep -m 1 -P '\\-\\-\\d\\d\\d\\d\\-\\d\\d\\-\\d\\d \\d\\d:\\d\\d:\\d\\d\\-\\-[ ]+' wget.log | awk -F '/' '{print \$(NF-1)}'`;
   }
   print("1 finalname = [$finalname]\n");
   $finalname = (split('\n', $finalname))[0]; # Getting rid of trailing EOL
   print("2 finalname = [$finalname]\n");

   if (substr($finalname, 0, 4) eq 'usp-') {
      $finalname = substr($finalname, 4);
   }
   if (substr($finalname, 0, 3) eq 'usp') {
      $finalname = substr($finalname, 3);
   }
   if (substr($finalname, 0, 3) ne "$iform") {
      $finalname = "${iform}-${finalname}";
   }
   print("3 finalname = [$finalname]\n");

   system("mv wget.log ${iform}.wget.log");

   print "\n======================== $urlpage\n======================== $tmpfilemp3name\n\n";
   if ((-e "${finalname}.mp3") && (! -z "${finalname}.mp3")) {
      print("File ${finalname}.mp3 already exists\n\n");
   }
   else {
      system("rm -f $tmpfilemp3name") if (-e $tmpfilemp3name);
      if (system("wget -nc $urlmp3 -o wget.log -o wget.log -O $tmpfilemp3name")) {
         print("Cannot wget $urlmp3\n");
      }
      else {
         print("$urlmp3 downloaded as $tmpfilemp3name\n");
         print("mv -v -f -T $tmpfilemp3name ${finalname}.mp3\n");
         system("mv -v -f -T $tmpfilemp3name ${finalname}.mp3");
      }
   }

   print "\n======================== $urlpage\n======================== $tmpfilepdfname\n\n";
   if ((-e "${finalname}.pdf") && (! -z "${finalname}.pdf")) {
      print("File ${finalname}.pdf already exists\n\n");
   }
   else {
      system("rm -f $tmpfilepdfname") if (-e $tmpfilepdfname);
      if (system("wget -nc $urlpdf -o wget.log -O $tmpfilepdfname")) {
         print("Cannot wget $urlpdf\n");
      }
      else {
         print("$urlpdf downloaded as $tmpfilepdfname\n");
         print("mv -v -f -T $tmpfilepdfname ${finalname}.pdf\n");
         system("mv -v -f -T \"$tmpfilepdfname\" ${finalname}.pdf");
      }
   }
}

