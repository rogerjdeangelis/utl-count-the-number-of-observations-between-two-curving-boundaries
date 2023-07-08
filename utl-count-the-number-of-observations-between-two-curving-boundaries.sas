%let pgm=utl-count-the-number-of-observations-between-two-curving-boundaries;

utl-count-the-number-of-observations-between-two-curving-boundaries
The equations does not have to be linear, but we need closed form equations.
An equation can be approximated using connect the dots or splines.

github
https://tinyurl.com/vmp9pz5r
https://github.com/rogerjdeangelis/utl-count-the-number-of-observations-between-two-curving-boundaries


      Solutions
            1. SAS/WPS datastep
            2. SAS/WPS SQL
            3. WPS proc R sql
            4. R sql
            5. Python sql
            6. Native R
            7. Native Python and wps proc python

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

options validvarname=upcase;

libname sd1 "d:/sd1";

data have;
  do x= 0 to 1 by .05;
    y = round(uniform(1334),0.001);
    output;
  end;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  WORK.HAVE total obs=21 07MAY2023:07                                                                                   */
/*                                                       0.00      0.25      0.50      0.75      1.00                     */
/*  Obs      X      Y     Equations                           ---+---------+---------+---------+---------+----            */
/*                                                            |                                              |            */
/*    1    0.00   0.740   upr=(2/3)*x +1/3  UPPER LINE        |                                              |            */
/*    2    0.05   0.098                                   1.0 +                                          /   + 1.0        */
/*    3    0.10   0.366   lwr=(5/7)*x       LOWER LINE        |                      Y                 /     |            */
/*    4    0.15   0.038                                       |                                      /       |            */
/*    5    0.20   0.418                                       |       count=4                      /         |            */
/*    6    0.25   0.016                                       |                                  /  Y        |            */
/*    7    0.30   0.334                                       |                        Y       /             |            */
/*    8    0.35   0.277                                   0.8 +                    Y         /               + 0.8        */
/*    9    0.40   0.425                                       |                            /upr=(2/3)Yx +1/3 |            */
/*   10    0.45   0.800                                       |  Y                       /                   |            */
/*   11    0.50   0.971                                       |                        /                 /   |            */
/*   12    0.55   0.843                                       |                      /       Y   Y     /     |            */
/*   13    0.60   0.428                                       |                    /       Y         /       |            */
/*   14    0.65   0.624                                   0.6 +                  /                 /         + 0.6        */
/*   15    0.70   0.670                                       |                /                 /           |            */
/*   16    0.75   0.457                                       |              /                 /             |            */
/*   17    0.80   0.664                                       |            /                 /      Y        |            */
/*   18    0.85   0.366                                       |          /                 /   Y             |            */
/*   19    0.90   0.004                                       |        / Y       Y       /                   |            */
/*   20    0.95   0.161                                   0.4 +      /                 /                     + 0.4        */
/*   21    1.00                                               |    / Y               /             Y         |            */
/*                                                            |  /           Y     /                         |            */
/*                                                            |       count=9    /                           |            */
/*                                                            |                /                             |            */
/*                                                            |                                              |            */
/*                                                        0.2 +              / lwr=(5/7)Yx;                + 0.2          */
/*                                                            |            /                           Y     |            */
/*                                                            |          /                                   |            */
/*                                                            |    Y   /  count=8                        Y   |            */
/*                                                            |      /                                       |            */
/*                                                            |    /   Y                                     |            */
/*                                                        0.0 +  /         Y                         Y       + 0.0        */
/*                                                            |                                              |            */
/*                                                            ---+---------+---------+---------+---------+----            */
/*                                                             0.00      0.25      0.50      0.75      1.00               */
/*                                                                                                                        */
/*                                                                                    X                                   */
/*                                                   For each Y point, you need to find out whether the y value is higher */
/*                                                   than each line at the equivalent x value.                            */
/*                                                                                                                        */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                    __                        _       _            _
/ |  ___  __ _ ___   / /_      ___ __  ___   __| | __ _| |_ __ _ ___| |_ ___ _ __
| | / __|/ _` / __| / /\ \ /\ / / `_ \/ __| / _` |/ _` | __/ _` / __| __/ _ \ `_ \
| | \__ \ (_| \__ \/ /  \ V  V /| |_) \__ \| (_| | (_| | || (_| \__ \ ||  __/ |_) |
|_| |___/\__,_|___/_/    \_/\_/ | .__/|___/ \__,_|\__,_|\__\__,_|___/\__\___| .__/
                                |_|                                         |_|
*/

options validvarname=upcase;

proc datasets lib=sd1 nodetails nolist;
 delete want;
run;quit;

libname sd1 "d:/sd1";

data sd1.have;
  do x= 0 to 1 by .05;
    y = round(uniform(1334),0.001);
    output;
  end;
run;quit;


/*---- You do not need to FCMP but it externalizes the functions         ----*/
options cmplib = (work.functions);
proc fcmp outlib=work.functions.uprlwr;

function upr(x);
    upr=(2/3)*x +1/3;
return(upr);
endsub;

function lwr(x);
    lwr=(5/7)*x;
return(lwr);
endsub;

run;quit;

data want (keep=upr btw lwr);
  retain upr btw lwr 0;
  set sd1.have end=dne;
  select;
     when (y gt upr(x)) upr=upr+1;
     when (y ge lwr(x)) btw=btw+1;
     when (y lt lwr(x)) lwr=lwr+1;
  end; /*---- leave off otherwise to force an error?                     ----*/

  if dne then output;

run;quit;
/*
__      ___ __  ___
\ \ /\ / / `_ \/ __|
 \ V  V /| |_) \__ \
  \_/\_/ | .__/|___/
         |_|
*/
%utl_submit_wps64x('

libname sd1 "d:/sd1";

proc datasets lib=sd1 nodetails nolist;
 delete want;
run;quit;

options cmplib = (work.functions);
proc fcmp outlib=work.functions.uprlwr;

function upr(x);
    upr=(2/3)*x +1/3;
return(upr);
endsub;

function lwr(x);
    lwr=(5/7)*x;
return(lwr);
endsub;

run;quit;

data sd1.want (keep=upr btw lwr);
  retain upr btw lwr 0;
  set sd1.have end=dne;
  select;
     when (y gt upr(x)) upr=upr+1;
     when (y ge lwr(x)) btw=btw+1;
     when (y lt lwr(x)) lwr=lwr+1;
  end; /*---- leave off otherwise to force an error?                     ----*/

  if dne then output;

run;quit;

proc print data=sd1.want;
run;quit;
');

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/* The WPS System                                                                                                         */
/*                                                                                                                        */
/* Obs    UPR    BTW    LWR                                                                                               */
/*                                                                                                                        */
/*  1      4      9      8                                                                                                */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*___                          __         _             _
|___ \  __      ___ __  ___   / /__  __ _| |  ___  __ _| |
  __) | \ \ /\ / / `_ \/ __| / / __|/ _` | | / __|/ _` | |
 / __/   \ V  V /| |_) \__ \/ /\__ \ (_| | | \__ \ (_| | |
|_____|   \_/\_/ | .__/|___/_/ |___/\__, |_| |___/\__, |_|
                 |_|                   |_|           |_|
*/

options validvarname=upcase;

proc datasets lib=sd1 nodetails nolist;
 delete want;
run;quit;

libname sd1 "d:/sd1";

data sd1.have;
  do x= 0 to 1 by .05;
    y = round(uniform(1334),0.001);
    output;
  end;
run;quit;

options cmplib = (work.functions);
proc fcmp outlib=work.functions.uprlwr;

function upr(x);
    upr=(2/3)*x +1/3;
return(upr);
endsub;

function lwr(x);
    lwr=(5/7)*x;
return(lwr);
endsub;

run;quit;

proc sql;
 select
    place
   ,count(*) as cnt
 from
   ( select
      case
        when (y gt upr(x)) then "UPR"
        when (y ge lwr(x)) then "BTW"
        when (y lt lwr(x)) then "LWR"
        else "ERR"
      end as place
    from
       sd1.have
   )
 group
   by place
;quit;

/*
__      ___ __  ___
\ \ /\ / / `_ \/ __|
 \ V  V /| |_) \__ \
  \_/\_/ | .__/|___/
         |_|
*/

%utl_submit_wps64x('

libname sd1 "d:/sd1";

options cmplib = (work.functions) validvarname=any;
proc fcmp outlib=work.functions.uprlwr;

function upr(x);
    upr=(2/3)*x +1/3;
return(upr);
endsub;

function lwr(x);
    lwr=(5/7)*x;
return(lwr);
endsub;

run;quit;

proc sql;
 select
    place
   ,count(*) as cnt
 from
   ( select
      case
        when (y gt upr(x)) then "UPR"
        when (y ge lwr(x)) then "BTW"
        when (y lt lwr(x)) then "LWR"
        else "ERR"
      end as place
    from
       sd1.have
   )
 group
   by place
;quit;
');

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/* The WPS System                                                                                                         */
/*                                                                                                                        */
/*   place       cnt                                                                                                      */
/*   ---------------                                                                                                      */
/*   BTW           9                                                                                                      */
/*   LWR           8                                                                                                      */
/*   UPR           4                                                                                                      */
/*                                                                                                                        */
/**************************************************************************************************************************/

options validvarname=upcase;

proc datasets lib=sd1 nodetails nolist;
 delete want;
run;quit;

libname sd1 "d:/sd1";

data sd1.have;
  do x= 0 to 1 by .05;
    y = round(uniform(1334),0.001);
    output;
  end;
run;quit;

/*----  Note you need to use the decimal point to maintain num floats?   ----*/

%utl_submit_r64x('
  library(haven);
  library(sqldf);
  have<-read_sas("d:/sd1/have.sas7bdat");
  want <- sqldf("
     select
        place
       ,count(*) as cnt
     from
       (
        select
          case
            when y >  (2./3.)*x +1./3. then \"UPR\"
            when y >= (5./7.)*x        then \"BTW\"
            when y <= 5.*x/7.          then \"LWR\"
            else \"ERR\"
          end as place
        from
           have
       )
     group
        by place
     ");
   want;
');

/*
 _ __
| `__|
| |
|_|

*/

%utl_submit_r64x('
  library(haven);
  library(sqldf);
  have<-read_sas("d:/sd1/have.sas7bdat");
  have;
  want <- sqldf("
     select
        place
       ,count(*) as cnt
     from
       ( select
          case
            when (y > ((2/3)*x+1/3) ) then \"UPR\"
            when (y >= (5/7)*x      ) then \"BTW\"
            when (y <= (5/7)*x      ) then \"LWR\"
            else \"ERR\"
          end as place
        from
          have
       )
     group
       by place
    ");
   want;
');

/*___                _   _                             _
| ___|   _ __  _   _| |_| |__   ___  _ __    ___  __ _| |
|___ \  | `_ \| | | | __| `_ \ / _ \| `_ \  / __|/ _` | |
 ___) | | |_) | |_| | |_| | | | (_) | | | | \__ \ (_| | |
|____/  | .__/ \__, |\__|_| |_|\___/|_| |_| |___/\__, |_|
        |_|    |___/                                |_|
*/


proc datasets lib=sd1 nodetails nolist;
 delete want;
run;quit;

libname sd1 "d:/sd1";

data sd1.have;
  do x= 0 to 1 by .05;
    y = round(uniform(1334),0.001);
    output;
  end;
run;quit;

%utl_pybeginx;
parmcards4;
from os import path
import pandas as pd
import xport
import xport.v56
import pyreadstat
import numpy as np
from pandasql import sqldf
mysql = lambda q: sqldf(q, globals())
from pandasql import PandaSQL
pdsql = PandaSQL(persist=True)
sqlite3conn = next(pdsql.conn.gen).connection.connection
sqlite3conn.enable_load_extension(True)
sqlite3conn.load_extension('c:/temp/libsqlitefunctions.dll')
mysql = lambda q: sqldf(q, globals())
have, meta = pyreadstat.read_sas7bdat("d:/sd1/have.sas7bdat")
print(have);
res = pdsql("""
     select
        place
       ,count(*) as cnt
     from
       (
        select
          case
            when y >  (2./3.)*x +1./3. then \"UPR\"
            when y >= (5./7.)*x        then \"BTW\"
            when y <= 5.*x/7.          then \"LWR\"
            else \"ERR\"
          end as place
        from
           have
       )
     group
        by place
     """);
print(res);
;;;;
%utl_pyend;


/**************************************************************************************************************************/
/*                                                                                                                        */
/*    place  cnt                                                                                                          */
/*                                                                                                                        */
/*  0   BTW    9                                                                                                          */
/*  1   LWR    8                                                                                                          */
/*  2   UPR    4                                                                                                          */
/*                                                                                                                        */
/**************************************************************************************************************************/


/*__                 _   _
 / /_    _ __   __ _| |_(_)_   _____   _ __
| `_ \  | `_ \ / _` | __| \ \ / / _ \ | `__|
| (_) | | | | | (_| | |_| |\ V /  __/ | |
 \___/  |_| |_|\__,_|\__|_| \_/ \___| |_|

*/

%utl_submit_r64('
     library(haven);
     have<-read_sas("d:/sd1/have.sas7bdat");
     attach(have);
     upr<-sum(Y >  (2./3.)*X +1./3. );
     lwr<-sum(Y <= 5.*X/7.);
     btw<- sum( (Y <=  (2./3.)*X +1./3. )*(Y > 5.*X/7.)) ;
     res<-data.frame(upr=upr,btw=btw,lwr=lwr);
     print(res);
     ');

/**************************************************************************************************************************/
/*                                                                                                                        */
/*    upr btw lwr                                                                                                         */
/*                                                                                                                        */
/*  1   4   9   8                                                                                                         */
/*                                                                                                                        */
/**************************************************************************************************************************/


/*____               _   _                         _   _
|___  |  _ __   __ _| |_(_)_   _____   _ __  _   _| |_| |__   ___  _ __
   / /  | `_ \ / _` | __| \ \ / / _ \ | `_ \| | | | __| `_ \ / _ \| `_ \
  / /   | | | | (_| | |_| |\ V /  __/ | |_) | |_| | |_| | | | (_) | | | |
 /_/    |_| |_|\__,_|\__|_| \_/ \___| | .__/ \__, |\__|_| |_|\___/|_| |_|
                                      |_|    |___/
*/

*best;
%utl_submit_py64_310x('
import numpy as nd;
import pandas as pd;
import pyreadstat;
df, meta = pyreadstat.read_sas7bdat("d:/sd1/have.sas7bdat");
upr = float(df.loc[df["Y"] > (2./3.)*df["X"] +1./3., "X"].count());
lwr = float(df.loc[df["Y"] <= 5.*df["X"]/7         , "X"].count());
btw = float(df["X"].count() - upr - lwr);
want=pd.DataFrame([[upr,btw,lwr]],columns=["upr","btw","lwr"]);
print(want);
');

/*
__      ___ __  ___
\ \ /\ / / `_ \/ __|
 \ V  V /| |_) \__ \
  \_/\_/ | .__/|___/
         |_|
*/

%utl_submit_wps64x('
libname sd1 "d:/sd1";
proc python;
export data=sd1.have python=df;
submit;
import numpy as np;
import pandas as pd;
upr = float(df.loc[df["Y"] > (2./3.)*df["X"] +1./3., "X"].count());
lwr = float(df.loc[df["Y"] <= 5.*df["X"]/7         , "X"].count());
btw = float(df["X"].count() - upr - lwr);
want=pd.DataFrame([[upr,btw,lwr]],columns=["upr","btw","lwr"]);
print(want);
endsubmit;
import data=sd1.want_py python=want;
run;quit;
');

proc print data=want_py;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*     upr  btw  lwr                                                                                                      */
/*                                                                                                                        */
/*  0  4.0  9.0  8.0                                                                                                      */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
