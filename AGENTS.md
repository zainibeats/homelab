# AGENTS.md

## Rules to Follow
- **Conciseness:** Be brief and direct unless asked for detail.                                                                                          
- **Verification:** Always verify the success of a command/tool before proceeding.                                                                       
- **Context First:** Prioritize project files and `agentmemory` over general knowledge.                                                                  
- **Ambiguity:** Ask for clarification immediately if user intent is unclear.                                                                            
- **Safety:** Do not perform destructive operations (deleting files, overwriting large configs) without confirming the current state first.              
- **Transparency:** If unsure about a specific path or dependency, point it out rather than guessing.

## Workflow
1. **Analyze:** Read the necessary files and gather context before suggesting any changes.                                                               
2. **Plan:** Provide a high-level plan of the changes you intend to make. Wait for user approval if the change is significant.                           
3. **Execute:** Perform changes in small, logical increments.                                                                                            
4. **Verify:** After each major step, run a command (lint, test, or grep) to confirm the change worked as expected.
