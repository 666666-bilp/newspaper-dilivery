<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.*"%>
<% SysUser user = (SysUser) session.getAttribute("user"); if (user == null) { response.sendRedirect("index.jsp"); return; }
   List<Customer> customers = (List<Customer>) session.getAttribute("customers");
   List<Community> communities = (List<Community>) session.getAttribute("communities");
   if (customers == null || communities == null) { response.sendRedirect("CustomerServlet?action=list"); return; } %>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>客户管理</title>
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
  <div class="page-title">客户管理</div>

  <div class="card">
    <div class="card-title">添加客户</div>
    <form method="post" action="CustomerServlet">
      <div class="form-line">
        <input type="text" name="name" placeholder="客户姓名" required>
        <input type="text" name="phone" placeholder="联系电话">
        <input type="text" name="address" placeholder="详细地址">
        <select name="communityId" required>
          <option value="">所属社区</option>
          <% for(Community c : communities) { %><option value="<%=c.getId()%>"><%=c.getName()%></option><% } %>
        </select>
        <button type="submit" class="btn btn-blue">添加</button>
      </div>
    </form>
  </div>

  <div class="card">
    <div class="card-title">客户列表 <span class="count">共 <%=customers.size()%> 人</span></div>
    <div class="table-wrap"><table>
      <thead><tr><th>ID</th><th>姓名</th><th>电话</th><th>地址</th><th>所属社区</th><th>操作</th></tr></thead>
      <tbody>
      <% for (Customer c : customers) { %>
      <tr><td><%=c.getId()%></td><td><%=c.getName()%></td><td><%=c.getPhone()%></td>
        <td><%=c.getAddress()%></td><td><%=c.getCommunityName()%></td>
        <td><a class="btn btn-red btn-sm" href="CustomerServlet?action=delete&id=<%=c.getId()%>" onclick="return confirm('确定删除该客户？')">删除</a></td></tr>
      <% } %>
      </tbody>
    </table></div>
  </div>
</div>
</body></html>
