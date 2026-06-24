<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.*"%>
<% SysUser user = (SysUser) session.getAttribute("user"); if (user == null) { response.sendRedirect("index.jsp"); return; }
   List<SysUser> sysUsers = (List<SysUser>) session.getAttribute("sysUsers");
   if (sysUsers == null) { response.sendRedirect("UserManageServlet?action=list"); return; } %>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>用户管理</title>
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
  <div class="page-title">用户管理</div>

  <div class="two-col">
  <div class="card">
    <div class="card-title">添加用户</div>
    <form method="post" action="UserManageServlet">
      <div class="form-stack">
        <div class="form-item"><label>用户名</label><input type="text" name="username" required></div>
        <div class="form-item"><label>密码</label><input type="password" name="password" required></div>
        <div class="form-item"><label>角色</label><select name="role"><option>管理员</option><option>操作员</option></select></div>
        <button type="submit" class="btn btn-blue">添加用户</button>
      </div>
    </form>
  </div>

  <div class="card">
    <div class="card-title">修改密码</div>
    <form method="post" action="UserManageServlet">
      <input type="hidden" name="action" value="changePwd">
      <div class="form-stack">
        <div class="form-item"><label>选择用户</label>
          <select name="id" required>
            <option value="">-- 请选择 --</option>
            <% for(SysUser u : sysUsers) { %><option value="<%=u.getId()%>"><%=u.getUsername()%>（<%=u.getRole()%>）</option><% } %>
          </select></div>
        <div class="form-item"><label>新密码</label><input type="password" name="newPassword" required></div>
        <button type="submit" class="btn btn-green">修改密码</button>
      </div>
    </form>
  </div>
  </div>

  <div class="card">
    <div class="card-title">用户列表 <span class="count">共 <%=sysUsers.size()%> 人</span></div>
    <div class="table-wrap"><table>
      <thead><tr><th>ID</th><th>用户名</th><th>角色</th><th>创建时间</th><th>操作</th></tr></thead>
      <tbody>
      <% for (SysUser u : sysUsers) { %>
      <tr><td><%=u.getId()%></td><td><%=u.getUsername()%></td>
        <td><span class="badge <%= "管理员".equals(u.getRole()) ? "badge-active" : "badge-stop" %>"><%=u.getRole()%></span></td>
        <td><%=u.getCreatedAt() != null ? u.getCreatedAt() : ""%></td>
        <td><a class="btn btn-red btn-sm" href="UserManageServlet?action=delete&id=<%=u.getId()%>" onclick="return confirm('确定删除该用户？')">删除</a></td></tr>
      <% } %>
      </tbody>
    </table></div>
  </div>
</div>
</body></html>
