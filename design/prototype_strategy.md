Document Context: **What?** This document describes the strategy and tactics for the OS2borgerpc development, as I perceived them in my (Software Architect role & DevOps Engineer role) discussion with Agente (Product Owner role & Software Engineer role). **Why?** I recommend keeping the scope of the prototyping effort as minimal as possible, but as big as is needed for the effort to achieve its intended goal. I am rewriting the intended features we discussed into the language of strategy and tactics, as this makes it easier to structure code, prioritize features, and to explain the code to future developers.

Date of conversation: June 11, 2026

---

# Strategy 

At some point "soon after the end of the summer holidays" (August 10th, 2026), the OS2borgerpc product owner wants to present a OS2borgerpc prototype to a group of municipal employees. The goal is to convince them that the OS2borgerpc project is worth supporting financially. Funding is needed to ensure that the production version of OS2borgerpc can be built until April 2027, when free upstream software updates for the current version cease.

The OS2borgerpc product owner wants to counter the following potential concerns that attendants might have about the solutions:

**Who?** A local IT administrator who is considering supporting OS2Skole.
1. **Concern:** "Will I be able to adjust the Client PCs(\*) to the needs of my municipality?" **Response:** "I am being shown a live example of how I'll be able to change the local configuration(\*) in ways that seem relevant to my use-case, and I am being shown the effects of this configuration change on the Client PC."
2. **Concern:** "Will this solution make me run around with USB sticks to patch local configuration?" **Response:** (a) "I am being shown a live example how I can apply the local configuration centrally" and (b) "I am being shown a live example that this configuration change involves only little manual labor."
3. **Concern:** "Will I have to navigate a complicated configuration interface where I'm prone to make mistakes?" **Response:** "I am being shown a live example that I'll be able to change the local configuration using interfaces that I feel comfortable."
4. **Concern:** "If there's an issue in one of the Client PCs, will I be able to know before end-users start having issues and complaining?" **Response:** "I am being shown a live example of how I can monitor the health of the Client PCs."

Besides, the following **quality characteristic** is crucial: The prototype must be developed in a way that some of the logic, or at least the discoveries made during development, can be re-used when the actual product is being developed.

_Note:_ This list of concerns is lacking justifications for the in-progress user login functionality and the setup of desktop apps. I recommend evaluating the underlying hypotheses behind the development of those features also.

**(\*) Proposed language standards:**
- "Client PC": Client Machines that the OS2borgerpc system is being applied to
- "Local Configuration": The configuration layer that is being applied within the Local Context (i.e. by a local administration or municipality)

## Underlying hypotheses

- The presentation will have a critical amount of attendants of the "local IT administrator" role.
- Having the support of attendants of the "local IT administrator" role will lead to financial support for the OS2borgerpc project.
- Attendants of the "local IT administrator" role's most likely and most important concerns are the four concerns listed above.
- The responses listed above are necessary to alleviate the attendants potential concerns.
- The responses listed above are sufficient to alleviate the attendants potential concerns.

# Tactical considerations

- Code execution during the Container built is currently managed through ansible, which is an unusual tool to use for this use-case. **Why?** The team developing the prototype expresses higher productivity when using with ansible instead of coding directly in bash. **Recommendation** We need to ensure that ansible is used in a way that it can later be seamlessly removed from the solution and we need to document this decision carefully.
- The config repository currently exposes a lot of parameters that are not relevant to the intended user (local IT administrator). **Recommendation** Cleaning up the interface between config repo and code repo is important, and possible, but might require adding some logic between components. For the sake of the prototype, it might be possible to only document the need for a solution, but otherwise keep the code as is. We may be able to address the local IT administrator attendant's "complicated configuration" concern without addressing this issue at this time. I recommend that we keep this issue at a lower priority for now, and see how many problems it causes as we continue developing the prototype.
