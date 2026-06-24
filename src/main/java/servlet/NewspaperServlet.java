package servlet;

import db.DB;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import model.Newspaper;
import java.io.IOException;

public class NewspaperServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        String action = req.getParameter("action");
        DB db = new DB();
        if ("delete".equals(action)) {
            db.deleteNewspaper(Integer.parseInt(req.getParameter("id")));
            resp.sendRedirect("NewspaperServlet?action=list");
        } else {
            req.getSession().setAttribute("newspapers", db.listNewspapers());
            resp.sendRedirect("newspaper.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        DB db = new DB();
        Newspaper n = new Newspaper();
        n.setName(req.getParameter("name"));
        n.setPrice(Double.parseDouble(req.getParameter("price")));
        n.setStock(Integer.parseInt(req.getParameter("stock")));
        n.setType(req.getParameter("type"));
        boolean ok;
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            n.setId(Integer.parseInt(idStr));
            ok = db.updateNewspaper(n);
        } else {
            ok = db.addNewspaper(n);
        }
        resp.getWriter().println(ok ? "<script>alert('操作成功');location.href='NewspaperServlet?action=list';</script>"
                                    : "<script>alert('操作失败');history.back();</script>");
    }
}
