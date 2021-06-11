using Grader
using Test

@testset "Grader.jl" begin
    # Test whether evalasmodule is working correctly for a basic problem.
    @testset "evalasmodule" begin
        golden_code = """x=2
        y = x * 3
        """

        student_code = """x=2
        y = x + x + x
        z = 4
        """

        golden_result = Grader.evalasmodule(golden_code)
        student_result = Grader.evalasmodule(student_code)


        @testset "correct x" begin 
            @test golden_result.x == student_result.x
        end
        @testset "correct y" begin 
            @test golden_result.y ≈ student_result.y
        end    
        @testset "correct z only in student code" begin
            @test_throws UndefVarError golden_result.z
            @test student_result.z == 4
        end

        @testset "Throws ParseError for syntax error" begin
            syntaxerr = "x= @@@"
            @test_throws Base.Meta.ParseError Grader.evalasmodule(syntaxerr)
        end
    end

    @testset "grade problem" begin
        @testset "correct answer" begin
            goldencode = """x=2
            y = x * 3
            """
            studentcode = """x=2
            y = x + x + x
            """

            p = Problem()
            golden = rungolden!(p, goldencode)
            student = runstudent!(p, studentcode)

            grade!(p, "y", "check y", 2, :($student.y ≈ $golden.y), "y is incorrect")

            @test length(p.tests) == 1
            @test p.tests[1].max_points == 2
            @test p.tests[1].points == 2
            @test p.score ≈ 1
        end

        @testset "partially correct answer" begin
            goldencode = """x=2
            y = x * 3
            z = y + 2
            """
            studentcode = """x=2
            y = x + x + x
            z = y + 3
            """

            p = Problem()            
            golden = rungolden!(p, goldencode)
            student = runstudent!(p, studentcode)

            grade!(p, "y", "check y", 2, :($student.y ≈ $golden.y), "y is incorrect")
            grade!(p, "z", "check z", 8, :($student.z ≈ $golden.z), "z is incorrect")

            @test length(p.tests) == 2
            @test p.tests[1].max_points == 2
            @test p.tests[2].max_points == 8
            @test p.tests[1].points == 2
            @test p.tests[2].points == 0
            @test p.tests[2].message == "z is incorrect"
            @test p.score ≈ 0.2
        end

        @testset "error in student code" begin
            goldencode = """x=2
            y = x * 3
            """
            studentcode = """x=2
            y = x + x + xx
            """

            p = Problem()
            golden = rungolden!(p, goldencode)
            student = runstudent!(p, studentcode)

            grade!(p, "y", "check y", 2, :($student.y ≈ $golden.y), "y is incorrect")

            @test !p.gradable
            @test p.message == "There was an error running your code, please see information below."
        end

        @testset "error in golden code" begin
            goldencode = """x=2
            y = x * 3y
            """
            studentcode = """x=2
            y = x + x + x
            """

            p = Problem()
            golden = rungolden!(p, goldencode)
            student = runstudent!(p, studentcode)

            @test !p.gradable
            @test p.message == "Internal grading error, please notify instructor."
        end

        @testset "student missing variable" begin
            goldencode = """x=2
            y = x * 3
            """
            studentcode = """x=2
            """

            p = Problem()
            golden = rungolden!(p, goldencode)
            student = runstudent!(p, studentcode)

            grade!(p, "y", "check y", 2, :($student.y ≈ $golden.y), "y is incorrect")

            @test p.tests[1].output == "\nUndefVarError: y not defined"
            @test p.tests[1].message == "y is incorrect"
        end

        @testset "pl_JSON" begin
            goldencode = """x=2
            y = x * 3
            z = y + 2
            """
            studentcode = """x=2
            y = x + x + x
            z = y + 3
            """

            p = Problem()            
            golden = rungolden!(p, goldencode)
            student = runstudent!(p, studentcode)

            grade!(p, "y", "check y", 2, :($student.y ≈ $golden.y), "y is incorrect")
            grade!(p, "z", "check z", 8, :($student.z ≈ $golden.z), "z is incorrect")

            s = IOBuffer()
            pl_JSON(s, p)
            jsondata = String(take!(s))

            @test jsondata == """{"gradable":true,"score":0.2,"message":"","output":"","images":[],"tests":[{"name":"y","description":"check y","points":2,"max_points":2,"message":"","output":"","images":[]},{"name":"z","description":"check z","points":0,"max_points":8,"message":"z is incorrect","output":"","images":[]}]}"""

            @test length(p.tests) == 2
            @test p.tests[1].max_points == 2
            @test p.tests[2].max_points == 8
            @test p.tests[1].points == 2
            @test p.tests[2].points == 0
            @test p.tests[2].message == "z is incorrect"
            @test p.score ≈ 0.2
        end
    end
end