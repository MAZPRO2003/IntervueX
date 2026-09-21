from typing import List, Optional, Any
from pydantic import BaseModel, Field

class CodeExecutionRequest(BaseModel):
    code: str
    language: str = "python"  # python, sql
    problem_id: Optional[str] = None
    custom_inputs: Optional[List[str]] = None

class TestCaseResult(BaseModel):
    test_id: int
    input_val: str
    expected_output: str
    actual_output: str
    passed: bool
    execution_time_ms: float

class CodeExecutionResult(BaseModel):
    success: bool
    stdout: str
    stderr: str
    execution_time_ms: float
    time_complexity: str
    space_complexity: str
    code_critique: str
    tests_passed_count: int
    total_tests_count: int
    test_results: List[TestCaseResult] = []
