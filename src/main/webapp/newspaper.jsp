<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.*"%>
<% SysUser user = (SysUser) session.getAttribute("user"); if (user == null) { response.sendRedirect("index.jsp"); return; }
   List<Newspaper> newspapers = (List<Newspaper>) session.getAttribute("newspapers");
   if (newspapers == null) { response.sendRedirect("NewspaperServlet?action=list"); return; } %>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>报纸管理</title>
<link rel="stylesheet" href="style.css?v=2"></head>
<body>
<div class="topbar">
  <div class="topbar-brand">报纸投递管理系统</div>
  <div class="topbar-nav">
    <a href="main.jsp">返回主页</a>
    <span class="topbar-user"><%= user.getUsername() %></span>
  </div>
</div>
<div class="page">
  <div class="page-title">报纸管理</div>

  <div class="card">
    <div class="card-title">添加报纸</div>
    <form method="post" action="NewspaperServlet">
      <div class="form-line">
        <input type="text" name="name" placeholder="报纸名称" required>
        <input type="number" name="price" placeholder="单价(元)" step="0.01" required style="width:90px">
        <input type="number" name="stock" placeholder="库存" required style="width:80px">
        <select name="type"><option>日报</option><option>周报</option><option>周刊</option></select>
        <button type="submit" class="btn btn-blue">添加</button>
      </div>
    </form>
  </div>

  <div class="card">
    <div class="card-title">报纸列表 <span class="count">共 <%=newspapers.size()%> 种</span></div>
    <div class="table-wrap"><table>
      <thead><tr><th>ID</th><th>名称</th><th>单价(元)</th><th>库存</th><th>类型</th><th>操作</th></tr></thead>
      <tbody>
      <% for (Newspaper n : newspapers) { %>
      <tr><td><%=n.getId()%></td><td><%=n.getName()%></td><td><%=String.format("%.2f", n.getPrice())%></td>
        <td><%=n.getStock()%></td><td><%=n.getType()%></td>
        <td><a class="btn btn-red btn-sm" href="NewspaperServlet?action=delete&id=<%=n.getId()%>" onclick="return confirm('确定删除？')">删除</a></td></tr>
      <% } %>
      </tbody>
    </table></div>
  </div>
</div>
</body></html>
