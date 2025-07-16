<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Roboto&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background-color: #fafafa;
        }
        h1 {
            text-align: center;
        }
        .group-header th {
            font-size: 200%;
            background-color: #007BFF;
            color: white;
        }
        .sub-header th {
            font-size: 150%;
        }
        table, th, td {
            border: 1px solid black;
            border-collapse: collapse;
            white-space: nowrap;
            padding: .3em;
            text-align: center;
        }
        table {
            margin: 0 auto;
            padding: 10px;
            width: 100%;
            table-layout: fixed;
        }
        .severity {
            text-align: center;
            font-weight: bold;
            color: #fafafa;
        }
        .severity-LOW .severity { background-color: #5fbb31; }
        .severity-MEDIUM .severity { background-color: #e9c600; }
        .severity-HIGH .severity { background-color: #ff8800; }
        .severity-CRITICAL .severity { background-color: #e40000; }
        .severity-UNKNOWN .severity { background-color: #747474; }
        .severity-LOW { background-color: #5fbb3160; }
        .severity-MEDIUM { background-color: #e9c60060; }
        .severity-HIGH { background-color: #ff880060; }
        .severity-CRITICAL { background-color: #e4000060; }
        .severity-UNKNOWN { background-color: #74747460; }
        table tr td:first-of-type {
            font-weight: bold;
        }
        tr:hover {
            background-color: #f5f5f5;
        }

        @media print {
            body {
                width: 210mm;
                height: 297mm;
                margin: 20mm; /* Adjust as necessary */
            }
            table {
                table-layout: fixed; /* This will make all columns equal width */
            }
            /* Change the font size for print view */
            body, td, th {
                font-size: 10pt;
            }
            td, th {
                word-wrap: break-word;
            }
            tr:hover {
                background-color: #ffffff;
            }
        }
    </style>
    <title>{{- escapeXML ( index . 0 ).Target }} - Trivy Report</title>
    <script>
      window.onload = function() {
        document.querySelectorAll('td.links').forEach(function(linkCell) {
          var links = [].concat.apply([], linkCell.querySelectorAll('a'));
          [].sort.apply(links, function(a, b) {
            return a.href > b.href ? 1 : -1;
          });
          links.forEach(function(link, idx) {
            if (links.length > 3 && 3 === idx) {
              var toggleLink = document.createElement('a');
              toggleLink.innerText = "Toggle more links";
              toggleLink.href = "#toggleMore";
              toggleLink.setAttribute("class", "toggle-more-links");
              linkCell.appendChild(toggleLink);
            }
            linkCell.appendChild(link);
          });
        });
        document.querySelectorAll('a.toggle-more-links').forEach(function(toggleLink) {
          toggleLink.onclick = function() {
            var expanded = toggleLink.parentElement.getAttribute("data-more-links");
            toggleLink.parentElement.setAttribute("data-more-links", "on" === expanded ? "off" : "on");
            return false;
          };
        });
      };
    </script>
  </head>
<body>
  <div class="container">
    {{- if . }}
    <h1>{{- escapeXML ( index . 0 ).Target }} - Trivy Report</h1>
    <table style="width: 100%;">
    {{- range . }}
      <tr class="group-header"><th colspan="6">{{ .Type | toString | escapeXML }}</th></tr>
      {{- if (eq (len .Vulnerabilities) 0) }}
      <tr><th colspan="5">No Vulnerabilities found</th></tr>
      {{- else }}
      <tr class="sub-header">
        <th>Package</th>
        <th>Vulnerability ID</th>
        <th>Severity</th>
        <th>Installed Version</th>
        <th>Fixed Version</th>
        <th>Links</th>
      </tr>
        {{- range .Vulnerabilities }}
      <tr class="severity-{{ escapeXML .Vulnerability.Severity }}">
        <td class="pkg-name">{{ escapeXML .PkgName }}</td>
        <td>{{ escapeXML .VulnerabilityID }}</td>
        <td class="severity">{{ escapeXML .Vulnerability.Severity }}</td>
        <td class="pkg-version">{{ escapeXML .InstalledVersion }}</td>
        <td>{{ escapeXML .FixedVersion }}</td>
        <td class="links" data-more-links="off">
          {{- range .Vulnerability.References }}
          <a href={{ escapeXML . | printf "%q" }}>{{ escapeXML . }}</a>
          {{- end }}
        </td>
      </tr>
        {{- end }}
      {{- end }}
      {{- if (eq (len .Misconfigurations ) 0) }}
      <tr><th colspan="6">No Misconfigurations found</th></tr>
      {{- else }}
      <tr class="sub-header">
        <th>Type</th>
        <th>Misconf ID</th>
        <th>Check</th>
        <th>Severity</th>
        <th>Message</th>
      </tr>
        {{- range .Misconfigurations }}
      <tr class="severity-{{ escapeXML .Severity }}">
        <td class="misconf-type">{{ .Type | toString | escapeXML }}</td>
        <td>{{ escapeXML .ID }}</td>
        <td class="misconf-check">{{ escapeXML .Title }}</td>
        <td class="severity">{{ escapeXML .Severity }}</td>
        <td class="link" data-more-links="off" style="white-space:normal;">
          {{ escapeXML .Message }}
          <br>
            <a href={{ escapeXML .PrimaryURL | printf "%q" }}>{{ escapeXML .PrimaryURL }}</a>
          </br>
        </td>
      </tr>
        {{- end }}
      {{- end }}
    {{- end }}
    </table>
    {{- else }}
    <h1>Trivy Returned Empty Report</h1>
    {{- end }}
    <hr>
  </div>
</body>
</html>
