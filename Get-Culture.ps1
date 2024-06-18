[System.Globalization.Cultureinfo]::GetCultures("AllCultures").DisplayName | sort > languages.txt


Get-Culture | Format-List -Property *
<#
PS C:\GitHub\PowerShellGoodies> Get-Culture | Format-List -Property *


Parent                         : en
LCID                           : 1033
KeyboardLayoutId               : 1033
Name                           : en-US
IetfLanguageTag                : en-US
DisplayName                    : English (United States)
NativeName                     : English (United States)
EnglishName                    : English (United States)
TwoLetterISOLanguageName       : en
ThreeLetterISOLanguageName     : eng
ThreeLetterWindowsLanguageName : ENU
CompareInfo                    : CompareInfo - en-US
TextInfo                       : TextInfo - en-US
IsNeutralCulture               : False
CultureTypes                   : SpecificCultures, InstalledWin32Cultures, FrameworkCultures
NumberFormat                   : System.Globalization.NumberFormatInfo
DateTimeFormat                 : System.Globalization.DateTimeFormatInfo
Calendar                       : System.Globalization.GregorianCalendar
OptionalCalendars              : {System.Globalization.GregorianCalendar, System.Globalization.GregorianCalendar}
UseUserOverride                : True
IsReadOnly                     : False

#>


$Culture = Get-Culture
<#

LCID             Name             DisplayName                                                                       
----             ----             -----------                                                                       
1033             en-US            English (United States)
#>

$Culture | Format-List -Property *
<#
PS C:\GitHub\PowerShellGoodies> $Culture | Format-List -Property *


Parent                         : en
LCID                           : 1033
KeyboardLayoutId               : 1033
Name                           : en-US
IetfLanguageTag                : en-US
DisplayName                    : English (United States)
NativeName                     : English (United States)
EnglishName                    : English (United States)
TwoLetterISOLanguageName       : en
ThreeLetterISOLanguageName     : eng
ThreeLetterWindowsLanguageName : ENU
CompareInfo                    : CompareInfo - en-US
TextInfo                       : TextInfo - en-US
IsNeutralCulture               : False
CultureTypes                   : SpecificCultures, InstalledWin32Cultures, FrameworkCultures
NumberFormat                   : System.Globalization.NumberFormatInfo
DateTimeFormat                 : System.Globalization.DateTimeFormatInfo
Calendar                       : System.Globalization.GregorianCalendar
OptionalCalendars              : {System.Globalization.GregorianCalendar, System.Globalization.GregorianCalendar}
UseUserOverride                : True
IsReadOnly                     : False
#>

$Culture.Calendar
<#
PS C:\GitHub\PowerShellGoodies> $Culture.Calendar


MinSupportedDateTime : 01/01/0001 00:00:00
MaxSupportedDateTime : 12/31/9999 23:59:59
AlgorithmType        : SolarCalendar
CalendarType         : Localized
Eras                 : {1}
TwoDigitYearMax      : 2049
IsReadOnly           : False
#>

$Culture.DateTimeFormat
<#
PS C:\GitHub\PowerShellGoodies> $Culture.DateTimeFormat


AMDesignator                     : AM
Calendar                         : System.Globalization.GregorianCalendar
DateSeparator                    : /
FirstDayOfWeek                   : Monday
CalendarWeekRule                 : FirstDay
FullDateTimePattern              : MMMM d, yyyy HH:mm:ss
LongDatePattern                  : MMMM d, yyyy
LongTimePattern                  : HH:mm:ss
MonthDayPattern                  : MMMM d
PMDesignator                     : PM
RFC1123Pattern                   : ddd, dd MMM yyyy HH':'mm':'ss 'GMT'
ShortDatePattern                 : MM/dd/yyyy
ShortTimePattern                 : HH:mm
SortableDateTimePattern          : yyyy'-'MM'-'dd'T'HH':'mm':'ss
TimeSeparator                    : :
UniversalSortableDateTimePattern : yyyy'-'MM'-'dd HH':'mm':'ss'Z'
YearMonthPattern                 : MMMM yyyy
AbbreviatedDayNames              : {Sun, Mon, Tue, Wed...}
ShortestDayNames                 : {Su, Mo, Tu, We...}
DayNames                         : {Sunday, Monday, Tuesday, Wednesday...}
AbbreviatedMonthNames            : {Jan, Feb, Mar, Apr...}
MonthNames                       : {January, February, March, April...}
IsReadOnly                       : False
NativeCalendarName               : Gregorian Calendar
AbbreviatedMonthGenitiveNames    : {Jan, Feb, Mar, Apr...}
MonthGenitiveNames               : {January, February, March, April...}
#>

$Culture.DateTimeFormat.FirstDayOfWeek
<#
PS C:\GitHub\PowerShellGoodies> $Culture.DateTimeFormat.FirstDayOfWeek
Monday

#>

#Gets the current UI culture settings in the operating system.
Get-UICulture
<#
#>

Get-UICulture | Format-List *
<#
#>