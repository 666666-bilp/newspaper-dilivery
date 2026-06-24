<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.*"%>
<% SysUser user = (SysUser) session.getAttribute("user"); if (user == null) { response.sendRedirect("index.jsp"); return; }
   List<Deliverer> deliverers = (List<Deliverer>) session.getAttribute("deliverers");
   if (deliverers == null) { response.sendRedirect("DelivererServlet?action=list"); return; } %>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>发行员管理</title>
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
  <div class="page-title">发行员管理</div>

  <div class="card">
    <div class="card-title">添加发行员</div>
    <form method="post" action="DelivererServlet">
      <div class="form-line">
        <input type="text" name="name" placeholder="姓名" required>
        <input type="text" name="phone" placeholder="联系电话">
        <input type="text" name="idCard" placeholder="身份证号(18位)">
        <select name="status"><option value="在职">在职</option><option value="离职">离职</option></select>
        <button type="submit" class="btn btn-blue">添加</button>
      </div>
    </form>
  </div>

  <div class="card">
    <div class="card-title">发行员列表 <span class="count">共 <%=deliverers.size()%> 人</span></div>
    <div class="table-wrap"><table>
      <thead><tr><th>ID</th><th>姓名</th><th>电话</th><th>身份证号</th><th>状态</th><th>操作</th></tr></thead>
      <tbody>
      <% for (Deliverer d : deliverers) { %>
      <tr><td><%=d.getId()%></td><td><%=d.getName()%></td><td><%=d.getPhone()%></td><td><%=d.getIdCard()%></td>
        <td><span class="badge <%= "在职".equals(d.getStatus()) ? "badge-active" : "badge-stop" %>"><%=d.getStatus()%></span></td>
        <td><a class="btn btn-red btn-sm" href="DelivererServlet?action=delete&id=<%=d.getId()%>" onclick="return confirm('确定删除？')">删除</a></td></tr>
      <% } %>
      </tbody>
    </table></div>
  </div>
</div>
</body></html>
