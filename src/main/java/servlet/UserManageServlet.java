package servlet;

import db.DB;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import model.SysUser;
import java.io.IOException;

public class UserManageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        String action = req.getParameter("action");
        DB db = new DB();
        if ("delete".equals(action)) {
            db.deleteSysUser(Integer.parseInt(req.getParameter("id")));
            resp.sendRedirect("UserManageServlet?action=list");
        } else {
            req.getSession().setAttribute("sysUsers", db.listSysUsers());
            resp.sendRedirect("userManage.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        String action = req.getParameter("action");
        DB db = new DB();
        if ("changePwd".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            String newPwd = req.getParameter("newPassword");
            boolean ok = db.changePassword(id, newPwd);
            resp.getWriter().println(ok ? "<script>alert('密码修改成功');location.href='UserManageServlet?action=list';</script>"
                                        : "<script>alert('修改失败');history.back();</script>");
        } else {
            SysUser u = new SysUser();
            u.setUsername(req.getParameter("username"));
            u.setPassword(req.getParameter("password"));
            u.setRole(req.getParameter("role"));
            boolean ok = db.addSysUser(u);
            resp.getWriter().println(ok ? "<script>alert('用户添加成功');location.href='UserManageServlet?action=list';</script>"
                                        : "<script>alert('添加失败');history.back();</script>");
        }
    }
}
