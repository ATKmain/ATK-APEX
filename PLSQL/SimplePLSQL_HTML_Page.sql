owa_util.mime_header('text/html');
htp.htmlOpen;
htp.headOpen;
htp.title('Title of the HTML File');
htp.headClose;

htp.bodyOpen( cattributes => 'TEXT="#000000" BGCOLOR="#FFFFFF"');
htp.header(1, 'Heading in the HTML File');
htp.para;
htp.print('Some text in the HTML file.');
htp.bodyClose;

htp.htmlClose;

---- OR All simply in HTML

owa_util.mime_header('text/html');
htp.print('<html>');
htp.print('<head>');
htp.print('<meta http-equiv="Content-Type" content="text/html">');
htp.print('<title>Title of the HTML File</title>');
htp.print('</head>');

htp.print('<body TEXT="#000000" BGCOLOR="#FFFFFF">');
htp.print('<h1>Heading in the HTML File</h1>');
htp.print('<p>Some text in the HTML file.');
htp.print('</body>');

htp.print('</html>');