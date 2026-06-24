package servlet;

import db.DB;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import model.Deliverer;
import java.io.IOException;

public class DelivererServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        String action = req.getParameter("action");
        DB db = new DB();
        if ("delete".equals(action)) {
            db.deleteDeliverer(Integer.parseInt(req.getParameter("id")));
            resp.sendRedirect("DelivererServlet?action=list");
        } else {
            req.getSession().setAttribute("deliverers", db.listDeliverers());
            resp.sendRedirect("deliverer.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        DB db = new DB();
        Deliverer d = new Deliverer();
        d.setName(req.getParameter("name"));
        d.setPhone(req.getParameter("phone"));
        d.setIdCard(req.getParameter("idCard"));
        d.setStatus(req.getParameter("status"));
        boolean ok;
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            d.setId(Integer.parseInt(idStr));
            ok = db.updateDeliverer(d);
        } else {
            ok = db.addDeliverer(d);
        }
        resp.getWriter().println(ok ? "<script>alert('操作成功');location.href='DelivererServlet?action=list';</script>"
                                    : "<script>alert('操作失败');history.back();</script>");
    }
}
