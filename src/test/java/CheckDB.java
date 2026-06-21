import com.mathify.dao.CourseDAO;
import com.mathify.model.Course;
import java.util.List;

public class CheckDB {
    public static void main(String[] args) throws Exception {
        CourseDAO dao = new CourseDAO();
        List<Course> courses = dao.getAllCourses();
        System.out.println("Number of courses found: " + courses.size());
        for (Course c : courses) {
            System.out.println("- " + c.getTitle());
        }
    }
}
