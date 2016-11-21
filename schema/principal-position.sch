<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    <pattern>
        <rule context="principal-position/id">
            <let name="basename" value="replace(base-uri(.), '^.*/(.*?)$', '$1')"/>
            <assert test="$basename = concat(., '.xml')">The id “<value-of select="."/>” does
                not match filename “<value-of select="$basename"/>”</assert>
            <assert test="matches(., '^[a-z-]+\d*$')">The id 
                “<value-of select="."/>” may contain only lower case letters, hyphens, and a trailing number</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="principal/id">
            <assert test="matches(., '^\w{1,4}-\d{4}-\w{1,4}$')">The id 
                “<value-of select="."/>” should take the form xxxx-yyyy-xxxx, where x is a lower case letter and y is a digit</assert>
            <let name="principal-position-id" value="root(.)/principal-position/id"/>
            <let name="expected-truncation" value="substring(tokenize($principal-position-id, '-')[last()], 1, 4)"/>
            <assert test="tokenize(., '-')[1] = $expected-truncation">The first portion of the id should be <value-of select="$expected-truncation"/></assert>
            <assert test="not(../date[. ne '']) or tokenize(., '-')[2] = substring(subsequence(..//date[. ne ''], 1, 1), 1, 4)">The second portion of the id should be the year portion of the first date in the record</assert>
            <assert test="tokenize(., '-')[3] = substring(tokenize(./following-sibling::person-id, '-')[1], 1, 4)">The third portion of the id should be the first (up to) four letters of the surname portion of a person's ID, e.g., “<value-of select="substring(tokenize(./following-sibling::person-id, '-')[1], 1, 4)"/>”</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="principal//date[. ne ''][parent::*/preceding-sibling::*[1][date ne '']]">
            <assert test=". ge ./parent::*/preceding-sibling::*[date ne ''][1]/date">Date ordering problem. expected this date to come after the preceding date.</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="person-id">
            <assert test="matches(., '^[a-z-]+\d?$')">The person-id “<value-of select="."/>” should only contain lower-case letters and hyphens, with an optional digit as the last character</assert>
            <assert test="doc-available(concat('../people/', substring(., 1, 1), '/', ., '.xml'))">The person-id “<value-of select="."/>” was not found in the people collection.</assert>
            <!--<assert test="doc(concat('http://localhost:8080/services/check-person-id?person-id=', .))/result/is-valid = 'true'">The person-id “<value-of select="."/>” was not found in the database.</assert>-->
        </rule>
    </pattern>
    <pattern>
        <rule context="date">
            <assert test="(. = '') or matches(., '^\d{4}$') or matches(., '^\d{4}-\d{2}$') or . castable as xs:date">Date should be yyyy-mm-dd, yyyy-mm, or empty</assert>
        </rule>
    </pattern>
    <pattern>
        <title>Report possible missing termination dates (skipped for Career Ambassadors)</title>
        <rule context="ended[date = ''][ancestor::principals]">
            <let name="start-date" value="(./preceding-sibling::started/date, ./preceding-sibling::appointed/date)[. ne ''][1]"/>
            <assert test="if (ancestor::principal-position/id ne 'career-ambassador' and substring($start-date, 1, 4) castable as xs:gYear) then (year-from-date(current-date()) - substring($start-date, 1, 4) cast as xs:integer lt 6) else true()">Missing termination date? More than 5 years has passed since appointment or entry on duty (<value-of select="substring($start-date, 1, 4)"/>).</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="last-modified-date">
            <assert test="xs:date(.) ge xs:date(./preceding-sibling::created-date)">Last
                updated date should come after the created date</assert>
        </rule>
    </pattern>
</schema>
