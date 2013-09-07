<%@ page import="httputils.*" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.nio.CharBuffer" %>
<%@ page import="java.nio.ByteBuffer" %>

<%
	/*
	out.println("<H1 ALIGN=CENTER>Request Headers</H1>\n");
	out.println("<B>Request Method: </B>" +request.getMethod() + "<BR>\n");
	out.println("<B>Request URI: </B>" + request.getRequestURI() + "<BR>\n");
	out.println("<B>Request Protocol: </B>" +request.getProtocol() + "<BR><BR>\n");
	out.println("<B>Path Requested: </B>" + request.getParameter("path") + "<BR>\n");
	out.println("<TABLE BORDER=1 ALIGN=CENTER>\n");
	out.println("<TR BGCOLOR=\"#FFAD00\">\n");
	out.println("<TH>Header Name<TH>Header Value");
	
	Enumeration headerNames = request.getHeaderNames();
	while(headerNames.hasMoreElements()) {
	  String headerName = (String)headerNames.nextElement();
	  out.println("<TR><TD>" + headerName);
	  out.println("    <TD>" + request.getHeader(headerName));
	}
	out.println("</TABLE>");
	*/
	HttpRequest req = new HttpRequest();
	if(request.getHeader("Authorization")!=null){
		System.out.println(String.format("Proxying %s, Authorization Header:%s",
										 request.getParameter("path"),
										 request.getHeader("Authorization")));
		req =   req.method(request.getMethod())
				   .header("Authorization", request.getHeader("Authorization"))
				   .header("Accept", "application/json")
				   .header("Content-Type", "application/json")
				   .url("https://"+request.getParameter("path"));
		HttpResponse theResp= Http.send(req);
		response.addHeader("Content-Type",theResp.getResponseContentType());
		out.print(theResp.getString());
	}else{
		out.println("No OAuth header found");
	}



%>
